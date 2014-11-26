require 'rails_helper'
require 'sidekiq/testing'
Sidekiq::Testing.fake!

describe ZenodoWorker do
  it "should call RestClient three times" do
    idea = build(:idea)
    idea.save

    ZenodoWorker.new.perform(idea.sha)
  end
end
