require 'rails_helper'

describe IdeasController, :type => :controller do
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

  describe "GET #index with JSON" do
    it "should respond with JSON array" do
      idea = create(:idea, :tags => [])
      get :index, :format => :json

      expect(response).to be_success
      expect(response.status).to eq(200)
      assert_equal hash_from_json(response.body).first["sha"], idea.sha
    end
  end

  describe "GET #index with Atom" do
    it "should respond with an Atom feed" do
      idea = create(:idea, :tags => [])
      get :index, :format => :atom

      expect(response).to be_success
      expect(response.status).to eq(200)
    end
  end

  describe "GET #show" do
    it "NOT LOGGED IN responds with success" do
      idea = create(:idea)
      get :show, :id => idea.to_param, :format => :html
      expect(response).to be_success
    end
  end

  describe "GET #show" do
    it "LOGGED IN responds with success" do
      user = create(:user)
      allow(controller).to receive_message_chain(:current_user).and_return(user)

      idea = create(:idea)
      get :show, :id => idea.to_param, :format => :html
      expect(response).to be_success
    end
  end

  describe "GET #show with JSON" do
    it "responds with JSON object" do
      idea = create(:idea)
      get :show, :id => idea.to_param, :format => :json
      expect(response).to be_success
      assert_equal hash_from_json(response.body)["sha"], idea.sha
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

end
