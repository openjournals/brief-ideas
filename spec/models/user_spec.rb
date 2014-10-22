require 'rails_helper'

describe User do
  it "should initialize properly" do
    user = create(:user)

    assert !user.sha.nil?
    expect(user.sha.length).to eq(32)
    assert !user.admin?
  end

  it "should know how to parameterize itself properly" do
    user = create(:user)

    expect(user.sha).to eq(user.to_param)
  end
end
