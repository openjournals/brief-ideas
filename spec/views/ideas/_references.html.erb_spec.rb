require 'rails_helper'

describe 'ideas/_references.html.erb' do
  context 'when the idea references another' do
    it 'should render the element' do
      parent = create(:idea)
      child = create(:idea, :parent_id => parent.id)

      render 'ideas/references', :idea => child

      expect(rendered).to match /#{parent.title}/
    end
  end
end
