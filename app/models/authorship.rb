class Authorship < ActiveRecord::Base
  belongs_to :idea
  belongs_to :user

  # Used for spam checking
  scope :today, lambda { where('created_at > ?', 1.day.ago) }

end
