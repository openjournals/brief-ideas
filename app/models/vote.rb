class Vote < ActiveRecord::Base
  belongs_to :user
  belongs_to :idea

  before_create :check_voter
  after_create :increment_idea_vote_count, :update_rating

  def check_voter
    if self.user == self.idea.creator
      return false
    elsif self.user.voter_for?(self.idea)
      return false
    else
      return true
    end
  end

  def increment_idea_vote_count
    Idea.increment_counter(:vote_count, idea.id)
  end

  def update_rating
    RatingWorker.perform_async(idea.sha)
  end
end
