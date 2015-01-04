require 'rails_helper'

describe IdeaReference do
  it { should belong_to(:idea) }
  it { should belong_to(:referenced) }

  it "should trigger RatingWorker jobs for references when created" do
    idea = create(:idea)
    2.times do
      citing_idea = create(:idea)
      citing_idea.idea_references.create(:referenced_id => idea.id)
    end

    expect(RatingWorker.jobs.size).to eq(2)
  end
end
