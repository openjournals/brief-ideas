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

  private

  def set_sha
    self.sha = SecureRandom.hex
  end
end
