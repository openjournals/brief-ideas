class IdeaReference < ActiveRecord::Base
  belongs_to :idea
  belongs_to :referenced, :class_name => "Idea"

  after_create :update_rating

  def update_rating
    RatingWorker.perform_async(referenced.sha)
  end
end
