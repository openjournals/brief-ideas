require 'rails_helper'

describe UsersController, :type => :controller do
  describe "GET #show" do
    it "NOT LOGGED IN responds with success" do
      user = create(:user)
      get :show, :id => user.to_param, :format => :html
      expect(response).to be_success
    end
  end
end
