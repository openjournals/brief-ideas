require 'rails_helper'

describe IdeaReference do
  it { should belong_to(:idea) }
  it { should belong_to(:referenced) }
end
