require 'rails_helper'
require 'sidekiq/testing'

describe Idea do
  before(:each) do
    Idea.destroy_all
    @redis ||= Redis.new(:url => ENV['REDISTOGO_URL'])
    @redis.del("tags-#{Rails.env}")
  end

  it { should belong_to(:user) }
  it { should have_many(:votes) }
  it { should have_many(:citations) }
  it { should have_many(:references) }

  it "should initialize properly (including queueing ZenodoWorker)" do
    paper = create(:idea)

    assert !paper.sha.nil?
    expect(paper.sha.length).to eq(32)
    expect(ZenodoWorker.jobs.size).to eq(1)
  end

  it "should be able to return formatted body" do
    paper = create(:idea, :body => "# Title")

    expect(paper.formatted_body).to eq("<h1>Title</h1>")
  end

  it "should santize bad stuff" do
    paper = create(:idea, :body => "Hello, <script>alert('I am a bad guy');</script>")

    expect(paper.formatted_body).to eq("<p>Hello, </p>")
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
    expect(idea.doi_badge_url).to eq("#{Rails.configuration.zenodo_url}/badge/doi/10.0000/zenodo.12345.svg")
  end

  # Tags
  it "should know what all of the tags available are" do
    create(:idea, :tags => ['so', 'very'])
    create(:idea, :tags => ['very', 'funky', 'yeah'])

    ['so', 'very', 'funky', 'yeah'].each do |tag|
      assert Idea.all_tags.include?(tag)
    end
    expect(Idea.all_tags.size).to eq(4)
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
    expect(Idea.count(:user_id => user.id)).to eq(5)
  end

  it "should be matched by a fuzzy search" do
    idea1 = create(:idea, :title => "A idea about who ideas rock")
    idea2 = create(:idea, :title => "A response to the idea that dogs cant lookup")

    result = Idea.fuzzy_search_by_title("dogs").all

    expect(result.first.sha).to eq(idea2.sha)
    expect(result.count).to eq(1)
  end

  it "should be selectable by searching for all tags" do
    idea = create(:idea, :tags => ["space", "dog"])

    expect(Idea.has_all_tags(["space", "dog"]).count).to eq(1)
    expect(Idea.has_all_tags(["space", "cat"]).count).to eq(0)
  end

  it "should be selectable by searching for any tags" do
    idea = create(:idea, :tags => ["space", "dog"])

    expect(Idea.has_any_tags(["space", "cat"]).count).to eq(1)
    expect(Idea.has_all_tags(["monkey", "cat"]).count).to eq(0)
  end

  # Parent/child relationships
  it "should know about its references" do
    reference_1 = create(:idea)
    idea = build(:idea)
    idea.idea_references.build(:referenced_id => reference_1.id)
    idea.save

    expect(idea.references.size).to eq(1)
    expect(idea.references).to eq([reference_1])
  end

  it "should know about its citations" do
    referenced_idea = create(:idea)
    citing_idea = create(:idea)
    citing_idea.idea_references.create(:referenced_id => referenced_idea.id)

    expect(referenced_idea.citations).to eq([citing_idea])
    assert referenced_idea.has_citations?
  end

  # Citation scoring and ranking

  # First with no citations
  it "should know how to score itself and associated citations" do
    idea = create(:idea)
    expect(idea.score_at(5)).to eq(0)
  end

  # With a citation
  it "should know how to score itself and associated citations" do
    referenced_idea = create(:idea)
    2.times do
      citing_idea = create(:idea)
      citing_idea.idea_references.create(:referenced_id => referenced_idea.id)
    end

    expect(referenced_idea.score_at(3)).to eq(6)
  end

  it "should know how to calculate it's own trending score from views" do
    idea = create(:idea, :view_count => 100)

    expect(idea.trending_score).to eq(10.0)
  end

  it "should know how to calculate it's own trending score from votes" do
    idea = create(:idea, :vote_count => 100)

    expect(idea.trending_score).to eq(100)
  end

  it "should know how to calculate it's own trending score" do
    idea = create(:idea, :vote_count => 100, :view_count => 100)
    2.times do
      citing_idea = create(:idea)
      citing_idea.idea_references.create(:referenced_id => idea.id)
    end

    expect(idea.trending_score).to eq(112.0)
  end

  it "should calculate nested citation scores correctly" do
    # parent_idea (2 citations at depth 1 so score: 2 * 1 = 2)
    #   - child_1 (1 citation at depth 2 so score: 1 * 2 = 2)
    #     - child_1_1 (0 citations at depth 3 so score: 0 * 3 = 0)
    #   - child_2 (2 citations at depth 2 so score: 2 * 2 = 4)
    #     - child_2_1 (0 citations at depth 3 so score: 0 * 3 = 0)
    #     - child_2_2 (1 citation at depth 3 so score: 1 * 3 = 3)
    #       - child_2_2_1 (0 citations at depth 4 so score: 0 * 4 = 0)

    idea = create(:idea, :vote_count => 0, :view_count => 0, :title => 'parent_idea')
    child_1 = create(:idea, :title => 'child_1')
    cite(idea, child_1)
    child_2 = create(:idea, :title => 'child_2')
    cite(idea, child_2)
    child_1_1 = create(:idea, :title => 'child_1_1')
    cite(child_1, child_1_1)
    child_2_1 = create(:idea, :title => 'child_2_1')
    cite(child_2, child_2_1)
    child_2_2 = create(:idea, :title => 'child_2_2')
    cite(child_2, child_2_2)
    child_2_2_1 = create(:idea, :title => 'child_2_2_1')
    cite(child_2_2, child_2_2_1)

    expect(idea.trending_score).to eq(11.0)
  end
end
