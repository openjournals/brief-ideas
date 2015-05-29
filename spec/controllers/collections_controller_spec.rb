require 'rails_helper'

describe CollectionsController, :type => :controller do
  render_views

  before(:each) do
    Collection.destroy_all
  end

  describe "GET #show" do
    it "NOT LOGGED IN should render" do
      collection = create(:collection, :name => "Best collection eva")

      get :show, :id => collection.to_param, :format => :html
      expect(response).to be_success
      expect(response.body).to match /Best collection eva/im
    end
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

  describe "POST #create" do
    it "LOGGED IN responds with success" do
      user = create(:user)
      allow(controller).to receive_message_chain(:current_user).and_return(user)
      collection_count = Collection.count
      idea = create(:published_idea)

      collection_params = {:name => "Boo ya collection", :idea_id => idea.sha}
      post :create, :collection => collection_params
      expect(response).to be_redirect # as it's created the thing
      expect(Collection.count).to eq(collection_count + 1)
    end
  end

  describe "POST #create with a bad idea_id" do
    it "LOGGED IN responds with warning" do
      user = create(:user)
      allow(controller).to receive_message_chain(:current_user).and_return(user)
      collection_count = Collection.count

      collection_params = {:name => "Boo ya collection", :idea_id => "foobar"}
      post :create, :collection => collection_params

      expect(response).to be_redirect # as it's redirecting to new
      expect(Collection.count).to eq(collection_count)
    end
  end

  describe "GET #show with JSON" do
    it "should respond with JSON array" do
      collection = create(:collection)
      idea = create(:published_idea)
      collection.ideas << idea
      get :show, :id => collection.to_param, :format => :json

      expect(response).to be_success
      expect(response.status).to eq(200)
      assert_equal hash_from_json(response.body)['ideas'].first["sha"], idea.sha
    end
  end

  describe "GET #index with Atom" do
    it "should respond with an Atom feed" do
      collection = create(:collection)
      idea = create(:published_idea)
      collection.ideas << idea
      get :show, :id => collection.to_param, :format => :atom

      expect(response).to be_success
      expect(response.status).to eq(200)
    end
  end
end
