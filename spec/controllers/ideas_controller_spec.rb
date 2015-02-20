require 'rails_helper'

describe IdeasController, :type => :controller do
  render_views

  before(:each) do
    Idea.destroy_all
    @redis ||= Redis.new(:url => ENV['REDISTOGO_URL'])
    @redis.del("tags-#{Rails.env}")
  end

  describe "GET #new" do
    it "NOT LOGGED IN responds with a redirect" do
      get :new, :format => :html
      expect(response).to be_redirect
    end
  end

  describe "GET #new" do
    it "LOGGED IN responds with a redirect" do
      user = create(:user)
      allow(controller).to receive_message_chain(:current_user).and_return(user)

      get :new, :format => :html
      expect(response).to be_success
    end
  end

  describe "GET #trending" do
    it "doesn't show the muted and deleted ideas" do
      idea = create(:published_idea, :muted => true, :title => "mute me")
      idea = create(:published_idea, :muted => false, :title => "not muted")
      idea = create(:published_idea, :deleted => true, :title => "deleted idea")

      get :trending

      expect(response.body).not_to match /mute me/im
      expect(response.body).to match /not muted/im
      expect(response.body).not_to match /deleted idea/im
    end
  end

  describe "GET #index" do
    it "doesn't show the muted and deleted ideas" do
      idea = create(:published_idea, :muted => true, :title => "mute me")
      idea = create(:published_idea, :muted => false, :title => "not muted")
      idea = create(:published_idea, :deleted => true, :title => "deleted idea")

      get :index

      expect(response.body).not_to match /mute me/im
      expect(response.body).to match /not muted/im
      expect(response.body).not_to match /deleted idea/im
    end
  end

  describe "GET #all" do
    it "doesn't show the deleted ideas or the muted ones" do
      idea = create(:published_idea, :muted => true, :title => "mute me")
      idea = create(:published_idea, :muted => false, :title => "not muted")
      idea = create(:published_idea, :deleted => true, :title => "deleted idea")

      get :all

      expect(response.body).not_to match /mute me/im
      expect(response.body).to match /not muted/im
      expect(response.body).not_to match /deleted idea/im
    end
  end

  describe "GET #index with JSON" do
    it "should respond with JSON array" do
      idea = create(:published_idea, :tags => ['tag'])
      get :index, :format => :json

      expect(response).to be_success
      expect(response.status).to eq(200)
      assert_equal hash_from_json(response.body).first["sha"], idea.sha
    end
  end

  describe "GET #index with Atom" do
    it "should respond with an Atom feed" do
      idea = create(:published_idea, :tags => ['tag'])
      get :index, :format => :atom

      expect(response).to be_success
      expect(response.status).to eq(200)
    end
  end

  # Trending

  describe "GET #trending with JSON" do
    it "should respond with JSON array" do
      idea = create(:published_idea, :tags => ['tag'], :score => 100)
      create(:idea, :score => 10)
      get :trending, :format => :json

      expect(response).to be_success
      expect(response.status).to eq(200)
      assert_equal hash_from_json(response.body).first["sha"], idea.sha
    end
  end

  describe "GET #show for unpublished idea" do
    it "NOT LOGGED IN responds with redirect" do
      idea = create(:idea)
      get :show, :id => idea.to_param, :format => :html
      expect(response).to be_redirect
    end
  end

  describe "GET #show for published idea" do
    it "NOT LOGGED IN responds with success" do
      idea = create(:published_idea)
      get :show, :id => idea.to_param, :format => :html
      expect(response).to be_success
    end
  end

  describe "GET #show for an unpublished idea" do
    it "LOGGED IN (not as author) responds with redirect" do
      user = create(:user)
      allow(controller).to receive_message_chain(:current_user).and_return(user)

      idea = create(:idea)
      get :show, :id => idea.to_param, :format => :html
      expect(response).to be_redirect
    end
  end

  describe "GET #show for an unpublished idea" do
    it "LOGGED IN (as author) responds with success" do
      user = create(:user)
      allow(controller).to receive_message_chain(:current_user).and_return(user)

      idea = create(:idea, :user => user)
      get :show, :id => idea.to_param, :format => :html
      expect(response).to be_success
    end
  end

  describe "GET #show for a published idea" do
    it "LOGGED IN (not as author) responds with success" do
      user = create(:user)
      allow(controller).to receive_message_chain(:current_user).and_return(user)

      idea = create(:published_idea)
      get :show, :id => idea.to_param, :format => :html
      expect(response).to be_success
    end
  end

  describe "GET #show with JSON" do
    it "responds with redirect" do
      idea = create(:idea)
      get :show, :id => idea.to_param, :format => :json
      expect(response).to be_redirect
    end
  end

  describe "GET #preview" do
    it "should return content that's been through the HTML pipeline" do
      idea_params = "# Aloha!"
      get :preview, :idea => idea_params
      expect(response.body).to eq("<h1>Aloha!</h1>")
    end
  end

  describe "POST #create" do
    it "NOT LOGGED IN responds with redirect" do
      idea_params = {:title => "Yeah whateva", :body => "something", :subject => "The > Good > Stuff", :tags => "Hello, my, name, is"}
      post :create, :idea => idea_params
      expect(response).to be_redirect
    end
  end

  describe "POST #create" do
    it "LOGGED IN responds with success" do
      user = create(:user)
      allow(controller).to receive_message_chain(:current_user).and_return(user)
      idea_count = Idea.count

      idea_params = {:title => "Yeah whateva", :body => "something", :subject => "The > Good > Stuff", :tags => "Hello, my, name, is"}
      post :create, :idea => idea_params
      expect(response).to be_redirect # as it's created the thing
      expect(Idea.count).to eq(idea_count + 1)

      # Need to call this to trigger the tag updating etc.
      Idea.last.publish

      # Tags should be made lower case on creation
      assert !Idea.all_tags.include?("Hello")
      assert Idea.all_tags.include?("hello")
    end
  end

  describe "GET #lookup" do
    it "responds with correct fuzzy search matches" do
      idea1 = create(:idea, title:"A idea about who ideas rock")
      idea2 = create(:idea, title:"A response to the idea that dogs cant lookup")

      get :lookup_title, :query => "dogs", :format => :json

      expect(response).to be_success
      assert_equal hash_from_json(response.body).first["sha"], idea2.sha
      assert_equal hash_from_json(response.body).count, 1
    end
  end

  describe "POST #create with a some citations in the body" do
    it "LOGGED IN responds with success" do
      parent_idea = create(:idea, :doi => "http://doi.arfon.doi.org")
      user = create(:user)
      allow(controller).to receive_message_chain(:current_user).and_return(user)
      idea_count = Idea.count

      idea_params = {:title => "Yeah whateva", :body => "something [A citation to Arfon's work](/ideas/#{parent_idea.sha}) and some more [A citation to Arfon's work](http://external.doi)", :subject => "The > Good > Stuff", :tags => "Hello, my, name, is"}
      post :create, :idea => idea_params
      expect(response).to be_redirect # as it's created the thing
      expect(Idea.count).to eq(idea_count + 1)

      # Citations/references
      expect(parent_idea.citations.count).to eq(1)
      expect(Idea.by_date.first.references.count).to eq(1)

      # Need to call this to trigger the tag updating etc.
      Idea.last.publish

      # Tags should be made lower case on creation
      assert !Idea.all_tags.include?("Hello")
      assert Idea.all_tags.include?("hello")
    end
  end

  # Idea dismissing

  describe "POST #hide" do
    it "NOT LOGGED IN responds with redirect" do
      post :hide, :id => "idsss"
      expect(response).to be_redirect
    end
  end

  describe "POST #hide" do
    it "LOGGED IN should hide the idea" do
      user = create(:user)
      allow(controller).to receive_message_chain(:current_user).and_return(user)
      idea = create(:published_idea, :title => "About to be hidden")
      request.env["HTTP_REFERER"] = ideas_path

      post :hide, :id => idea.sha
      assert user.seen_idea_ids.include?(idea.id)
    end
  end
end
