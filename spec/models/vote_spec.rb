require 'rails_helper'

describe Vote do
  it { should belong_to(:user) }
  it { should belong_to(:idea) }

  it "should not allow the creator of an idea to vote on it" do
    user = create(:user)
    idea = create(:idea, :user => user)
    user.vote_for!(idea)

    expect(idea.reload.current_vote).to eq(0)
  end

  it "should not allow the same user to vote twice on an idea" do
    user = create(:user)
    idea = create(:idea)
    user.vote_for!(idea)
    user.vote_for!(idea)

    expect(idea.reload.current_vote).to eq(1)
  end
end
