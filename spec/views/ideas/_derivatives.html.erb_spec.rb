require 'rails_helper'

describe 'ideas/_derivatives.html.erb' do
  context 'when the idea has children' do
    it 'should list them out' do
      idea = create(:idea)
      3.times do
        citing_idea = create(:published_idea)
        citing_idea.idea_references.create(:referenced_id => idea.id)
      end

      render 'ideas/derivatives', :idea => idea

      expect(rendered).to have_selector('li', :count => 3)
    end
  end
end
