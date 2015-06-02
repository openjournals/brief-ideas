require 'rails_helper'

describe 'ideas/new.html.erb' do
  context 'logged in' do
    it "WITHOUT reference should render properly" do
      user = create(:user)
      allow(view).to receive(:current_user).and_return(user)
      idea = Idea.new
      assign(:idea, idea)

      render :template => "ideas/new.html.erb"

      expect(rendered).to have_content user.nice_name
      expect(rendered).to have_selector('div.form-group', :count => 3)
      expect(rendered).to have_selector('div.references', :count => 0)
    end

    it "for user without an email should prompt them to add one" do
      user = create(:no_email_user)
      allow(view).to receive(:current_user).and_return(user)
      idea = Idea.new
      assign(:idea, idea)

      render :template => "ideas/new.html.erb"
      expect(rendered).to match /Please add an email address to your account before continuing/
    end
  end
end
