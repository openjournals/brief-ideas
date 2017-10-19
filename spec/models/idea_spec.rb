require 'rails_helper'
require 'sidekiq/testing'

describe Idea do
  before(:each) do
    Idea.destroy_all
    @redis ||= Redis.new(:url => ENV['REDISTOGO_URL'])
    @redis.del("tags-#{Rails.env}")
  end

  it { should have_many(:authors) }
  it { should have_many(:authorships) }
  it { should have_many(:votes) }
  it { should have_many(:citations) }
  it { should have_many(:references) }
  it { should have_many(:collection_ideas) }
  it { should have_many(:collections) }
  it { should have_attached_file(:attachment) }
  it { should validate_attachment_content_type(:attachment).
              allowing('image/png', 'image/gif', 'image/jpg', 'application/pdf',
              'application/zip', 'application/x-zip',
              'application/x-zip-compressed', 'application/octet-stream').
              rejecting('text/plain', 'text/xml') }
  it { should validate_attachment_size(:attachment).less_than(4.megabytes) }

  it "should initialize properly (including NOT queueing ZenodoWorker)" do
    paper = create(:idea)

    assert !paper.sha.nil?
    expect(paper.sha.length).to eq(32)
    expect(paper.state).to eq('pending')
    expect(ZenodoWorker.jobs.size).to eq(0)
    expect(RatingWorker.jobs.size).to eq(0)
  end

  it "should email the editor and author when submitted" do
    idea = create(:idea)
    idea.authors << create(:user)

    expect {idea.submit!}.to change { ActionMailer::Base.deliveries.count }.by(2)
  end

  it "should queue ZenodoWorker when published" do
    idea = create(:idea)
    idea.authors << create(:user)
    idea.publish!

    expect(ZenodoWorker.jobs.size).to eq(1)
  end

  it "should not save if it has more than 200 words" do
    long_string =
      "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam et pharetra libero. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Phasellus ultricies mauris posuere nisi dictum, sit amet fringilla orci lobortis. Cras accumsan egestas diam id molestie. Nulla non metus quis justo laoreet hendrerit. Integer convallis est laoreet, scelerisque neque eu, semper lectus. Vestibulum egestas enim id neque eleifend varius. Nam molestie justo sit amet massa pulvinar, ut commodo leo bibendum. Nullam id lacus ac eros sagittis ultrices. Curabitur molestie consequat dui, eget mollis eros ullamcorper et. Praesent venenatis cursus interdum. Integer velit nibh, aliquet eu felis eget, consequat tempor dui. Donec porta mi mauris, nec posuere leo dapibus sit amet. In lobortis efficitur metus, in consectetur leo mattis at. Ut varius aliquam interdum. Etiam sed sem ac lacus suscipit luctus ac id diam. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae; Vivamus euismod ante metus, ac accumsan elit tempor id. Sed fringilla nunc quis vestibulum rhoncus. Proin sodales ante eu sagittis malesuada. Nam consectetur sem in mi rutrum, a tempor lorem ullamcorper. Nam posuere quam sed felis blandit condimentum. Suspendisse condimentum neque vel egestas convallis. Cras maximus mattis justo, facilisis maximus arcu convallis a. Pellentesque non euismod arcu. Aenean ultricies, metus sit amet tempor."

    idea = build(:idea, :body => long_string)
    idea.valid?
    expect(idea.errors[:body]).to eq(["Your idea must be less than 200 words."])
  end

  it "should be properly ranked when searching for similar ideas" do
    paper1 = create(:published_idea, :title => 'Blah', :body => "The domestic cat (Felis catus or Felis silvestris catus) is a small, usually furry, domesticated, and carnivorous mammal. It is often called a housecat when kept as an indoor pet.")
    paper2 = create(:published_idea, :title => 'Foo', :body => "The domestic dog (Canis lupus familiaris) is a canid that is known as man's best friend. The dog was the first domesticated animal and has been widely kept as a working, hunting, and pet companion")
    paper3 = create(:published_idea, :title => 'Foo', :body => "Dogs are friends")

    results = Idea.similar_ideas("dogs are a man's best friend", 2)

    expect(results.last.id).to eq(paper2.id)
  end


  it "should be able to return formatted body" do
    paper = create(:idea, :body => "# Title")

    expect(paper.formatted_body).to eq("<h1>Title</h1>")
  end

  it "should be able to return formatted title" do
    paper = create(:idea, :title => "**Hello**")

    expect(paper.formatted_title).to eq("<p><strong>Hello</strong></p>")
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

  it "should not be created if the owner doesn't have an email" do
    user = create(:no_email_user)
    idea = build(:idea)
    idea.authors << user
    idea.save
    expect(idea.errors[:base]).to eq(["You can't submit an idea without all authors having a valid email associated with their account."])
  end

  it "should know who its #creator is" do
    user = create(:user)
    idea = create(:idea)
    idea.authors << user

    expect(idea.creator).to eq(user)
    assert idea.authors.include?(user)
    expect(idea.submitting_author).to eq(user)
  end

  it "should know who the #submitting_author is" do
    first_author = create(:user)
    idea = create(:idea)
    idea.authors << first_author
    idea.authors << create(:user)

    expect(idea.submitting_author).to eq(first_author)
  end

  # Preserving the first author attribution
  it "should preserve author ordering is" do
    first_author = create(:user)
    idea = create(:idea)
    idea.authors << first_author
    idea.authors << create(:user)

    expect(idea.authors.first).to eq(first_author)
  end

  # Twitter
  it "should know how to format single author for Twitter" do
    author = create(:user, :name => 'Doe, John')
    idea = create(:idea, :title => "Yawn fest")
    idea.authors << author

    expect(idea.tweet_users).to eq(author.nice_name)
  end

  # Twitter
  it "should know how to format multiple authors for Twitter" do
    author = create(:user, :name => 'Doe, John')
    second_author = create(:user, :name => "Smith, Hannibal")
    idea = create(:idea, :title => "Yawn fest")
    idea.authors << author
    idea.authors << second_author

    expect(idea.tweet_users).to eq("#{author.nice_name} et al.")
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
    idea1 = create(:idea, :tags => ['so', 'very'])
    idea1.authors << create(:user)
    idea1.publish

    idea2 = create(:idea, :tags => ['very', 'funky', 'yeah'])
    idea2.authors << create(:user)
    idea2.publish

    ['so', 'very', 'funky', 'yeah'].each do |tag|
      assert Idea.all_tags.include?(tag)
    end
    expect(Idea.all_tags.size).to eq(4)
  end

  # Rate limiting of Idea creation
  it "should only allow a User to create up to 5 ideas per day" do
    user = create(:user)

    5.times do
      idea = create(:idea)
      idea.authors << user
    end

    idea = build(:idea)
    idea.authors << user
    idea.save
    expect(idea.errors[:base]).to eq(["You've already created 5 ideas today, please come back tomorrow."])
    expect(Authorship.count(:user_id => user.id)).to eq(5)
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

  # Authorships
  it "adding author should send an email" do
    submitting_author = create(:user)
    idea = create(:idea)
    idea.authors << submitting_author
    new_author = create(:user)

    expect {idea.add_author!(new_author)}.to change { ActionMailer::Base.deliveries.count }.by(1)
  end

  # Idea rejection
  it "rejecting an idea should send a rejection email" do
    submitting_author = create(:user)
    idea = create(:idea)
    idea.authors << submitting_author

    expect {idea.reject!}.to change { ActionMailer::Base.deliveries.count }.by(1)
  end

  # Idea acceptance
  it "accepting an idea should send a acceptance email" do
    submitting_author = create(:user)
    idea = create(:idea)
    idea.authors << submitting_author

    expect {idea.publish!}.to change { ActionMailer::Base.deliveries.count }.by(1)
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
