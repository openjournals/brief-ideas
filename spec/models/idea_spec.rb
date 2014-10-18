require 'rails_helper'

describe Idea do
  it "should initialize properly" do
    paper = create(:idea)

    assert !paper.sha.nil?
    expect(paper.sha.length).to eq(32)
  end

  it "should be able to return formatted body" do
    paper = create(:idea, :body => "# Title")

    expect(paper.formatted_body).to eq("<h1>Title</h1>")
  end
end
