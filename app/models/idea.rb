require 'html/pipeline'
require 'twitter'

class Idea < ActiveRecord::Base
  acts_as_commentable
  include AASM

  aasm :column => :state do
    state :pending, :initial => true
    state :submitted
    state :published
    state :rejected

    event :submit do
      after do
        notify_editor
      end

      transitions :to => :submitted
    end

    event :publish do
      after do
        zenodo_create
        push_tags
        notify_acceptance
      end

      transitions :to => :published
    end

    event :reject do
      after do
        notify_rejection
      end

      transitions :to => :rejected
    end
  end

  has_many :votes
  has_many :audit_logs

  has_many :authorships
  has_many :authors, :class_name => "User", :through => :authorships, :source => 'user'

  has_many :collection_ideas
  has_many :collections, :through => :collection_ideas

  # Citations/references
  has_many :idea_references
  has_many :references, :through => :idea_references, :source => 'referenced'

  has_many :idea_citations, :class_name => 'IdeaReference', :foreign_key => 'referenced_id'
  has_many :citations, :through => :idea_citations, :source => 'idea'

  before_create :set_sha, :check_user_idea_count, :parse_references, :check_email

  scope :today, lambda { where('created_at > ?', 1.day.ago) }
  scope :recent, lambda { where('created_at > ?', 1.week.ago) }
  scope :by_date, -> { order('created_at DESC') }
  scope :trending, -> { order('score DESC') }
  scope :visible, -> { where('deleted = ? and muted = ? and state = ?', false, false, 'published') }
  # Don't want unsubmitted ideas in the admin view
  scope :admin_visible, -> { where('state != ?', 'pending') }
  scope :for_user, lambda { |user = nil| where('id NOT IN (?)', user.seen_idea_ids) unless user.nil? }

  scope :has_all_tags, ->(tags){ where("ARRAY[?]::varchar[] <@ tags::varchar[]", tags) }
  scope :has_any_tags, ->(tags){ where("ARRAY[?]::varchar[] && tags::varchar[]", tags) }

  scope :fuzzy_search_by_title, -> (title) { where("title ILIKE ?", "%#{title}%")}

  validates_presence_of :title, :body, :tags

  # Logging views of ideas with impressionist. Only one count per user session
  is_impressionable :counter_cache => true, :column_name => :view_count, :unique => :true

  # View helper methods
  def tags_list=(arg)
    tags = arg.split(',').map { |v| v.strip }
  end

  def tags_list
    tags.join(', ')
  end

  # TODO - work out what do do with these
  def parents
    references
  end

  def parent
    parents.first
  end

  def notify_acceptance
    Notification.acceptance_email(self).deliver
  end

  def notify_rejection
    Notification.rejection_email(self).deliver
  end

  def add_author!(new_author)
    unless authors.include?(new_author)
      authors << new_author
      Notification.authorship_email(self, new_author).deliver
    end
  end

  def submitting_author
    authorships.order('created_at ASC').first.user
  end

  # Can authors still be invited to this paper?
  def invitable_to?(user)
    return false unless pending?
    return false if authors.include?(user)
  end

  def can_become_author?(user)
    if published?
      return false, "This idea is already published"
    elsif rejected?
      return false, "This idea is was rejected"
    elsif authors.include?(user)
      return false, "You're already an author of this idea"
    else
      return true, "Author can be added"
    end
  end

  def visible_to?(user)
    if (authors.include?(user) || self.published?)
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
    authors.each do |author|
      unless author.email?
        errors[:base] << "You can't submit an idea without all authors having a valid email associated with their account."
        return false
      end
    end
  end

  # Posts a tweet with the idea title, author name and link and updates the
  # boolean 'tweeted' field
  #
  # Returns nothing
  def tweet!
    TWITTER.update("#{title.truncate(80)} - #{user.nice_name}\n\nhttp://beta.briefideas.org/ideas/#{sha}")
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

  def notify_editor
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
    authors.first
  end

  def formatted_creators
    authors.collect {|author| author.nice_name}.join(", ")
  end

  def formatted_title
    pipeline = HTML::Pipeline.new [
      HTML::Pipeline::MarkdownFilter,
      HTML::Pipeline::SanitizationFilter
    ]
    result = pipeline.call(title)
    result[:output].to_s
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

    # Need to check all authors
    authors.each do |author|
      if Authorship.today.where(:user_id => author.id).count >= 5
        self.errors[:base] << "You've already created 5 ideas today, please come back tomorrow."
        return false
      end
    end
  end
end
