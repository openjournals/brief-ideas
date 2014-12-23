require 'html/pipeline'

class Idea < ActiveRecord::Base
  belongs_to :user
  has_many :votes

  # Citations/references
  has_many :idea_references
  has_many :references, :through => :idea_references, :source => 'referenced'

  has_many :idea_citations, :class_name => 'IdeaReference', :foreign_key => 'referenced_id'
  has_many :citations, :through => :idea_citations, :source => 'idea'

  before_create :set_sha, :check_user_idea_count, :parse_references
  after_create :zenodo_create, :push_tags

  scope :today, lambda { where('created_at > ?', 1.day.ago) }
  scope :recent, lambda { where('created_at > ?', 1.week.ago) }

  scope :has_all_tags, ->(tags){ where("ARRAY[?]::varchar[] <@ tags::varchar[]", tags) }
  scope :has_any_tags, ->(tags){ where("ARRAY[?]::varchar[] && tags::varchar[]", tags) }

  scope :fuzzy_search_by_title, -> (title) { where("title ILIKE ?", "%#{title}%")}


  validates_presence_of :title, :body, :subject

  # Logging views of ideas with impressionist. Only one count per user session
  is_impressionable :counter_cache => true, :column_name => :view_count, :unique => :true

  # TODO - work out what do do with these
  def parents
    references
  end

  def parent
    parents.first
  end

  # TODO - test these regexes and work out what to do with non-JOBI references
  def parse_references
    globbed_references = body.scan(/(.*?\))/)

    globbed_references.each do |reference|
      url = reference.first.scan(/(?<=\().*(?=\))/).first
      next unless url

      if url.include?('users')
        # Do nothing for now when it's a mention of a user
      elsif idea = Idea.find_by_doi(url)
        # When this is an idea we know about, make a hard link
        self.idea_references.build(:referenced_id => idea.id)
      else
        # Just leave it in the body without doing anything.
      end
    end
  end

  def parent?
    parent
  end

  def children
    citations
  end

  def has_related_works?
    parent? || children
  end

  def to_param
    sha
  end

  def current_vote
    vote_count
  end

  def voted_on_by?(user)
    user.voter_for?(self)
  end

  def creator
    user
  end

  def formatted_body
    pipeline = HTML::Pipeline.new [
      HTML::Pipeline::MarkdownFilter,
      HTML::Pipeline::SanitizationFilter
    ]
    result = pipeline.call(body)
    result[:output].to_s
  end

  def zenodo_create
    ZenodoWorker.perform_async(sha)
  end

  def zenodo_keywords
    subject.blank? ? "" : subject
  end

  def formatted_tags
    tags.any? ? tags.join(', ') : ""
  end

  def formatted_doi
    doi.gsub('http://dx.doi.org/', '')
  end

  def doi_badge_url
    "#{Rails.configuration.zenodo_url}/badge/doi/#{formatted_doi}.svg"
  end

  def push_tags
    @redis ||= Redis.new(:url => ENV['REDISTOGO_URL'])
    tags.each { |tag| @redis.sadd("tags-#{Rails.env}", tag) }
  end

  def self.all_tags
    @redis ||= Redis.new(:url => ENV['REDISTOGO_URL'])
    @redis.smembers("tags-#{Rails.env}")
  end

private

  def set_sha
    self.sha = SecureRandom.hex
  end

  # Don't let people create more than 5 ideas in 24 hours
  def check_user_idea_count
    if Idea.today.count(:user => user) >= 5
      self.errors[:base] << "You've already created 5 ideas today, please come back tomorrow."
      return false
    end
  end
end
