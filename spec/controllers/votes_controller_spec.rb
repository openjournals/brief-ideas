require 'rails_helper'

describe VotesController, :type => :controller do
  render_views

  describe "JS POST #create" do
    it "NOT LOGGED IN responds with a redirect" do
      idea = create(:idea)
      post :create, :idea_id => idea.id, :format => :js

      expect(response).to be_redirect
      expect(idea.reload.votes.size).to eq(0)
    end

    it "LOGGED IN responds with JS" do
      user = create(:user)
      allow(controller).to receive_message_chain(:current_user).and_return(user)

      idea = create(:idea)
      post :create, :idea_id => idea.id, :format => :js

      expect(response).to be_success
      expect(idea.reload.votes.size).to eq(1)
    end
  end

  describe "HTML POST #create" do
    it "NOT LOGGED IN responds with a redirect" do
      idea = create(:idea)
      post :create, :idea_id => idea.id, :format => :html

      expect(response).to be_redirect
      expect(idea.reload.votes.size).to eq(0)
    end

    it "LOGGED IN responds with flash" do
      user = create(:user)
      allow(controller).to receive_message_chain(:current_user).and_return(user)

      idea = create(:idea)
      request.env["HTTP_REFERER"] = idea_path(idea)

      post :create, :idea_id => idea.id, :format => :html

      expect(response).to be_redirect # created as HTML redirects
      expect(idea.reload.votes.size).to eq(1)
      expect(flash[:notice]).to match /Vote created/
    end
  end
end
