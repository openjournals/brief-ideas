require 'rails_helper'

describe 'ideas/about.html.erb' do
  context 'NOT logged in' do
    it "should render properly" do
      allow(view).to receive(:current_user).and_return(nil)

      render :template => "ideas/about.html.erb"

      expect(rendered).to have_content 'Why are you doing this?'
    end
  end
end
