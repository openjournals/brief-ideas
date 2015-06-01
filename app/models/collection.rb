class Collection < ActiveRecord::Base
  belongs_to :user
  has_many :collection_ideas, :dependent => :destroy
  has_many :ideas, :through => :collection_ideas

  before_create :set_sha

  def to_param
    sha
  end

  def owner
    user
  end

private

  def set_sha
    self.sha = SecureRandom.hex
  end
end
