require 'html/pipeline'

class Idea < ActiveRecord::Base
  belongs_to :user
  has_many :votes
  before_create :set_sha, :check_user_idea_count
  after_create :zenodo_create

  scope :today, lambda { where('created_at > ?', 1.day.ago) }
  scope :recent, lambda { where('created_at > ?', 1.week.ago) }

  validates_presence_of :title, :body, :subject

  # TODO - perhaps make this a 'has_one' association?
  def parent
    Idea.find_by_id(parent_id)
  end

  def parent?
    parent
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
    filter = HTML::Pipeline::MarkdownFilter.new(body)
    filter.call
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
    "https://dev.zenodo.org/badge/doi/#{formatted_doi}.svg"
  end

  def self.all_tags
    Rails.cache.fetch("all_tags") do
      tags = []
      all.each { |idea| tags << idea.tags.collect(&:strip) }
      tags.flatten.uniq
    end
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
