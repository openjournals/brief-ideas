require 'rails_helper'

describe User do
  it { should have_many(:ideas) }
  it { should have_many(:votes) }
  it { should have_many(:collections) }

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

  it "should know how to format its name" do
    user = create(:user, :uid => "0000-0000-0000-1111", :name => "Einstein, Albert")

    expect(user.nice_name).to eq("Albert Einstein")
  end

  # Voting
  it "should know how to create a vote" do
    idea = create(:idea)
    user = create(:user)
    user.vote_for!(idea)

    expect(idea.reload.current_vote).to eq(1)
    assert user.voter_for?(idea)
  end

  it "should be matched by a fuzzy search" do
    user1 = create(:user, name:"cosmicbob21")
    user2 = create(:user, name:"earthyalice")

    result = User.fuzzy_search("bob").all

    expect(result.first.sha).to eq(user1.sha)
    expect(result.count).to eq(1)
  end
end
