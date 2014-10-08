require 'rails_helper'

describe User do
  it "should initialize properly" do
    user = create(:user)

    assert !user.sha.nil?
    expect(user.sha.length).to eq(32)
    assert !user.admin?
  end
end
