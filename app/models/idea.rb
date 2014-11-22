require 'html/pipeline'

class Idea < ActiveRecord::Base
  belongs_to :user
  before_create :set_sha, :check_user_idea_count
  after_create :zenodo_create

  scope :recent, lambda { where('created_at > ?', 1.week.ago) }

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

  def check_user_idea_count
    # TODO - make sure they've not created more than 5 ideas today
  end
end
