require 'html/pipeline'

class Idea < ActiveRecord::Base
  belongs_to :user
  before_create :set_sha
  after_create :zenodo_create

  def to_param
    sha
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
end
