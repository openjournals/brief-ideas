require 'rails_helper'

describe CollectionIdea do
  it { should belong_to(:idea) }
  it { should belong_to(:collection) }
end
