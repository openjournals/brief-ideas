require 'rails_helper'

describe Authorship do
  it { should belong_to(:user) }
  it { should belong_to(:idea) }
end
