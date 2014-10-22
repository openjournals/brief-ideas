require 'rails_helper'

describe IdeasController, :type => :controller do
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

  describe "GET #show" do
    it "NOT LOGGED IN responds with success" do
      idea = create(:idea)
      get :show, :id => idea.to_param, :format => :html
      expect(response).to be_success
    end
  end
end
