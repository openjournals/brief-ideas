require 'rails_helper'

describe 'users/show.html.erb' do
  context 'NOT logged in' do
    it "should render properly" do
      allow(view).to receive(:current_user).and_return(nil)
      user = create(:user)
      assign(:user, user)

      4.times do
        idea = create(:idea, :tags => ['Funky'], :user => user)
      end

      render :template => "users/show.html.erb"

      expect(rendered).to have_selector('div.idea', :count => 4)
      expect(rendered).to have_content user.nice_name
    end
  end
end
