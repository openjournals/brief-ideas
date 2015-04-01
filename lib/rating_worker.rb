class RatingWorker
  include Sidekiq::Worker

  def perform(idea_id)
    idea = Idea.find_by_sha(idea_id)
    calculate_score(idea_id)
  end

  def calculate_score(idea_id)
    idea = Idea.find_by_sha(idea_id)
    idea.update_attribute(:score, idea.trending_score)
  end
end
