require 'html/pipeline'
require 'twitter'

class Idea < ActiveRecord::Base
  include AASM

  aasm :column => :state do
    state :pending, :initial => true
    state :published
    state :rejected

    event :publish do
      after do
        zenodo_create
        push_tags
      end

      transitions :to => :published
    end

    event :reject do
      transitions :to => :rejected
    end
  end

  belongs_to :user
  has_many :votes
  has_many :audit_logs

  # Citations/references
  has_many :idea_references
  has_many :references, :through => :idea_references, :source => 'referenced'

  has_many :idea_citations, :class_name => 'IdeaReference', :foreign_key => 'referenced_id'
  has_many :citations, :through => :idea_citations, :source => 'idea'

  before_create :set_sha, :check_user_idea_count, :parse_references, :check_email
  after_create :notify

  scope :today, lambda { where('created_at > ?', 1.day.ago) }
  scope :recent, lambda { where('created_at > ?', 1.week.ago) }
  scope :by_date, -> { order('created_at DESC') }
  scope :trending, -> { order('score DESC') }
  scope :visible, -> { where('deleted = ? and muted = ? and state = ?', false, false, 'published') }
  scope :for_user, lambda { |user = nil| where('id NOT IN (?)', user.seen_idea_ids) unless user.nil? }

  scope :has_all_tags, ->(tags){ where("ARRAY[?]::varchar[] <@ tags::varchar[]", tags) }
  scope :has_any_tags, ->(tags){ where("ARRAY[?]::varchar[] && tags::varchar[]", tags) }

  scope :fuzzy_search_by_title, -> (title) { where("title ILIKE ?", "%#{title}%")}

  validates_presence_of :title, :body, :tags

  # Logging views of ideas with impressionist. Only one count per user session
  is_impressionable :counter_cache => true, :column_name => :view_count, :unique => :true

  # TODO - work out what do do with these
  def parents
    references
  end

  def parent
    parents.first
  end

  def visible_to?(user)
    if (creator == user || self.published?)
      return true
    elsif user
      return true if user.admin?
    else
      return false
    end
  end

  # Checks if the user has an email address on their record
  #
  # Returns nothing or false with some errors on [:base]
  def check_email
    unless self.user.email?
      errors[:base] << "You can't submit an idea without having a valid email associated with your account."
      return false
    end
  end

  # Posts a tweet with the idea title, author name and link and updates the
  # boolean 'tweeted' field
  #
  # Returns nothing
  def tweet!
    TWITTER.update("#{title} - #{user.nice_name}\n\nhttp://beta.briefideas.org/ideas/#{sha}")
    self.update_columns(:tweeted => true)
  end

  # TODO - test these regexes and work out what to do with non-JOBI references
  def parse_references
    globbed_references = body.scan(/(.*?\))/)

    globbed_references.each do |reference|
      url = reference.first.scan(/(?<=\().*(?=\))/).first
      next unless url

      if url.include?('users')
        # Do nothing for now when it's a mention of a user
      # FIXME - this is junk
      elsif url.include?('ideas') && idea = Idea.find_by_sha(url.gsub('/ideas/', ''))
        # When this is an idea we know about, make a hard link
        self.idea_references.build(:referenced_id => idea.id)
      else
        # Just leave it in the body without doing anything.
      end
    end
  end

  def notify
    Notification.submission_email(self).deliver
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

  def self.similar_ideas(query, limit=4)
    Idea.find_by_sql ["select * from ideas where state='published' order by ts_rank_cd(to_tsvector('english', ideas.title || ' ' || ideas.body), replace(plainto_tsquery(?)::text, ' & ', ' | ')::tsquery, 8) DESC Limit ? ", query, limit]
  end

  def has_citations?
    citations.any?
  end

  # Calculate the score for the citations at depth 'N'
  def score_at(depth)
    return self.citations.count * depth
  end

  # Method to walk all nodes of the citation tree, returning the citation and
  # depth 'N' for each element
  def traverse_tree(idea=self, depth=1, &blk)
    if idea.has_citations?
      blk.call(idea, depth)
      depth += 1
      idea.citations.each { |citation| traverse_tree(citation, depth, &blk) }
    else
      blk.call(idea, depth)
    end
  end

  # Walk the citation tree and calculate a ranking. This method should only be
  # called in a worker (see lib/rating_worker.rb)
  def citation_score
    total = 0
    traverse_tree do |citation, depth|
      total += citation.score_at(depth)
    end

    return total
  end

  def trending_score
    vote_count + (view_count.to_f / 10) + citation_score
  end

  # Admin actions
  def mute!
    self.update_columns(:muted => true)
  end

  # TODO remove this method
  def delete!
    self.update_columns(:deleted => true)
  end

private

  def set_sha
    self.sha = SecureRandom.hex
  end

  # Don't let people create more than 5 ideas in 24 hours
  def check_user_idea_count
    return true if Rails.env.development?
    if Idea.today.where(:user_id => user.id).count >= 5
      self.errors[:base] << "You've already created 5 ideas today, please come back tomorrow."
      return false
    end
  end
end
