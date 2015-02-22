require 'rating_worker'

desc 'Update ratings'
task :update_ratings => :environment do
  Idea.published.find_each do |idea|
    RatingWorker.perform_async(idea.sha)
  end

  Notification.ratings_email.deliver
end
