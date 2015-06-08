require 'rails_helper'

describe SearchController, :type => :controller do
  describe "GET #search with JSON when specifying tags" do
    it "should respond with just the tagged objects" do
      idea1 = create(:published_idea, :tags => ["space", "dog"])
      idea2 = create(:published_idea, :tags => ["space", "cat"])

      get :search, :format => :json, tags: "dog"

      expect(response).to be_success
      expect(response.status).to eq(200)
      assert_equal hash_from_json(response.body).first["sha"], idea1.sha
      assert_equal hash_from_json(response.body).count,  1
    end
  end

  describe "GET #search with JSON when specifying tags" do
    it "should respond with only published (visible) ideas" do
      idea1 = create(:published_idea, :tags => ["space", "dog"])
      idea2 = create(:published_idea, :tags => ["space", "cat"])
      idea3 = create(:idea, :tags => ["space", "cat"])

      get :search, :format => :json, tags: "space"

      expect(response).to be_success
      expect(response.status).to eq(200)
      assert_equal hash_from_json(response.body).count, 2
    end
  end
end
