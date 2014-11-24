require 'rails_helper'

describe 'ideas/show.html.erb' do
  context 'normally' do
    it "should render properly" do
      allow(view).to receive(:current_user).and_return(create(:user))
      idea = create(:idea)
      assign(:idea, idea)

      render :template => "ideas/show.html.erb"

      expect(rendered).to have_content idea.title
      expect(rendered).to have_content idea.user.name
      expect(rendered).to have_content 'New idea based on this'
    end
  end
end
