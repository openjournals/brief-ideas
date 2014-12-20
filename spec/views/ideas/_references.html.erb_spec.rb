require 'rails_helper'

describe 'ideas/_references.html.erb' do
  context 'when the idea references another' do
    it 'should render the element' do
      parent = create(:idea)
      citing_idea = create(:idea)
      citing_idea.idea_references.create(:referenced_id => parent.id)

      render 'ideas/references', :idea => citing_idea

      expect(rendered).to match /#{parent.title}/
    end
  end
end
