require 'rails_helper'

describe Collection do
  it { should belong_to(:user) }
  it { should have_many(:collection_ideas) }
  it { should have_many(:ideas) }
end
