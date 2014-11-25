require 'rails_helper'

describe 'ideas/show.html.erb' do
  context 'NOT logged in' do
    it "should render properly" do
      allow(view).to receive(:current_user).and_return(nil)
      idea = create(:idea, :tags => ['Funky'])
      assign(:idea, idea)

      render :template => "ideas/show.html.erb"

      expect(rendered).to have_content 'Sign in with ORCID'
      expect(rendered).to have_content idea.title
      expect(rendered).to have_content idea.user.name
      expect(rendered).to have_content 'New idea based on this'
      expect(rendered).to have_content 'Funky'
      expect(rendered).to have_content idea.created_at.strftime("%e/%m/%Y")
    end
  end

  context 'logged in' do
    it "should render properly" do
      user = create(:user)
      allow(view).to receive(:current_user).and_return(user)
      idea = create(:idea, :tags => [])
      assign(:idea, idea)

      render :template => "ideas/show.html.erb"

      expect(rendered).to have_content user.name
      expect(rendered).to have_content idea.title
      expect(rendered).to have_content idea.user.name
      expect(rendered).to have_content 'New idea based on this'
      expect(rendered).to have_content "This idea isn't tagged with anything"
      expect(rendered).to have_content idea.created_at.strftime("%e/%m/%Y")
    end
  end
end
