require 'rails_helper'
require 'sidekiq/testing'
Sidekiq::Testing.fake!

# TODO write some more meaningful assertions here.
describe RatingWorker do
  before(:each) do
    Sidekiq::Worker.clear_all
    Idea.destroy_all
  end

  it "should create the correct number of jobs" do
    referenced_idea = create(:idea)
    citing_idea = create(:idea)
    reference = citing_idea.idea_references.build(:referenced_id => referenced_idea.id)
    reference.save

    expect {
      RatingWorker.perform_async(referenced_idea.sha)
    }.to change(RatingWorker.jobs, :size).by(1)
  end
end
