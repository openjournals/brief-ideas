require 'rails_helper'

describe Idea do
  it { should belong_to(:user) }
  it { should have_many(:votes) }

  it "should initialize properly" do
    paper = create(:idea)

    assert !paper.sha.nil?
    expect(paper.sha.length).to eq(32)
  end

  it "should be able to return formatted body" do
    paper = create(:idea, :body => "# Title")

    expect(paper.formatted_body).to eq("<h1>Title</h1>")
  end

  it "should know how to parameterize itself properly" do
    idea = create(:idea)

    expect(idea.sha).to eq(idea.to_param)
  end

  it "should know what its current vote is" do
    idea = create(:idea, :vote_count => 100)

    expect(idea.current_vote).to eq(100)
  end

  it "should know if a user has voted for it" do
    idea = create(:idea)
    user = create(:user)
    create(:vote, :user => user, :idea => idea)

    assert idea.voted_on_by?(user)
  end

  it "should know who its #creator is" do
    user = create(:user)
    idea = create(:idea, :user => user)

    expect(idea.creator).to eq(user)
  end

  # Zenodo stuff
  it "should know how to format its keywords and tags for Zenodo" do
    idea = create(:idea, :subject => "Blah > Dooo > Daa", :tags => ['so', 'very', 'funky'])

    expect(idea.zenodo_keywords).to eq(idea.subject)
    expect(idea.formatted_tags).to eq("so, very, funky")
  end

  # DOI business
  it "should know how to handle DOIs in the views" do
    idea = create(:idea, :doi => "http://dx.doi.org/10.0000/zenodo.12345")

    expect(idea.formatted_doi).to eq("10.0000/zenodo.12345")
    # TODO - this will need changing when shipped to production Zenodo URL
    expect(idea.doi_badge_url).to eq("https://dev.zenodo.org/badge/doi/10.0000/zenodo.12345.svg")
  end

  # Tags
  it "should know what all of the tags available are" do
    create(:idea, :tags => ['so', 'very'])
    create(:idea, :tags => ['very', 'funky', 'yeah'])

    expect(Idea.all_tags).to eq(['so', 'very', 'funky', 'yeah'])
  end

  # Rate limiting of Idea creation
  it "should only allow a User to create up to 5 ideas per day" do
    user = create(:user)
    5.times do
      create(:idea, :user => user)
    end

    idea = build(:idea, :user => user)
    idea.save
    expect(idea.errors[:base]).to eq(["You've already created 5 ideas today, please come back tomorrow."])
    expect(Idea.count).to eq(5)
  end

  # Parent/child relationships
  it "should know about its parent" do
    parent = create(:idea)
    child = create(:idea, :parent_id => parent.id)

    expect(child.parent).to eq(parent)
  end

  it "should know about its parent" do
    parent = create(:idea)
    create(:idea, :parent_id => parent.id)
    create(:idea, :parent_id => parent.id)

    expect(parent.children.size).to eq(2)
  end
end
