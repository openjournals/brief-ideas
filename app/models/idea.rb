class Idea < ActiveRecord::Base
  belongs_to :user
  before_create :set_sha

  attr_accessor :sha

  def to_param
    sha
  end

  private

  def set_sha
    self.sha = SecureRandom.hex
  end
end
