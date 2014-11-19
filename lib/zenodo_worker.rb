class ZenodoWorker
  include Sidekiq::Worker

  def perform(idea_id)
    idea = Idea.find_by_sha(idea_id)

    create_deposit(idea)
    upload_files(idea)

    # Mark as published
    publish!(idea)
  end

  def create_deposit(idea)
    puts "CREATING ZENODO DEPOSIT FOR #{idea.sha}"
  end

  def upload_files(idea)
    puts "UPLOADING FILES FOR #{idea.sha}"
  end

  def publish!(idea)
    puts "PUBLISHED! #{idea.sha}"
  end
end
