require 'rails_helper'

describe Idea do
  it "should initialize properly" do
    paper = create(:idea)

    assert !paper.sha.nil?
    expect(paper.sha.length).to eq(32)
  end
end
