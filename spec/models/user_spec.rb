require 'rails_helper'

describe User do
  it { should have_many(:ideas) }
  it { should have_many(:votes) }

  it "should initialize properly" do
    user = create(:user)

    assert !user.sha.nil?
    expect(user.sha.length).to eq(32)
    assert !user.admin?
  end

  it "should know how to parameterize itself properly" do
    user = create(:user)

    expect(user.sha).to eq(user.to_param)
  end

  it "should know how to create its ORCID id" do
    user = create(:user, :uid => "0000-0000-0000-1111")

    expect(user.orcid_url).to eq("http://orcid.org/#{user.uid}")
  end

  # Voting
  it "should know how to create a vote" do
    idea = create(:idea)
    user = create(:user)
    user.vote_for!(idea)

    expect(idea.reload.current_vote).to eq(1)
    assert user.voter_for?(idea)
  end
end
