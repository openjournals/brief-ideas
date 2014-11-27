require 'rails_helper'
require 'sidekiq/testing'
Sidekiq::Testing.fake!

# TODO write some more assertions here.
describe ZenodoWorker do
  it "should assign a DOI to the idea" do
    idea = build(:idea)
    idea.save

    ZenodoWorker.new.perform(idea.sha)
    assert !idea.doi.blank?
  end
end
