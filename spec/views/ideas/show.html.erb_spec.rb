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
      expect(rendered).to have_content idea.formatted_creators
      expect(rendered).to have_content 'Funky'
      expect(rendered).to have_content idea.created_at.strftime("%e %b, %Y")
    end
  end

  context 'logged in as author' do
    it "should render properly" do
      user = create(:user)
      allow(view).to receive(:current_user).and_return(user)
      idea = create(:idea, :tags => ['jelly'])
      idea.authors << user
      assign(:idea, idea)

      render :template => "ideas/show.html.erb"

      expect(rendered).to have_content user.nice_name
      expect(rendered).to have_content idea.title
      expect(rendered).to have_content idea.formatted_creators
      expect(rendered).to have_content idea.created_at.strftime("%e %b, %Y")
      expect(rendered).to have_content 'pending acceptance'
    end
  end

  context 'logged in as author' do
    it "should render properly for rejected idea" do
      user = create(:user)
      allow(view).to receive(:current_user).and_return(user)
      idea = create(:rejected_idea, :tags => ['jelly'])
      idea.authors << user
      assign(:idea, idea)

      3.times do
        citing_idea = create(:published_idea)
        citing_idea.idea_references.create(:referenced_id => idea.id)
      end

      render :template => "ideas/show.html.erb"

      expect(rendered).to have_content user.nice_name
      expect(rendered).to have_content idea.title
      expect(rendered).to have_content idea.formatted_creators
      expect(rendered).to have_content idea.created_at.strftime("%e %b, %Y")
      expect(rendered).to have_content 'not accepted'
    end
  end

  context 'NOT logged in as viewer' do
    it "should only show published derivatives" do
      idea = create(:published_idea, :tags => ['jelly'])
      assign(:idea, idea)

      3.times do
        citing_idea = create(:published_idea)
        citing_idea.idea_references.create(:referenced_id => idea.id)
      end

      # This one shouldn't show
      citing_idea = create(:rejected_idea, :title => "Not published")
      citing_idea.idea_references.create(:referenced_id => idea.id)

      render :template => "ideas/show.html.erb"

      expect(rendered).to have_content idea.title
      expect(rendered).to have_content idea.formatted_creators
      expect(rendered).to have_content idea.created_at.strftime("%e %b, %Y")
      expect(rendered).not_to match /Not published/
      expect(rendered).to match /Please log in to add a comment/
    end
  end
end
