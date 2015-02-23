require 'rails_helper'
require 'sidekiq/testing'
Sidekiq::Testing.fake!

# TODO write some more meaningful assertions here.
describe OrcidWorker do
  before(:each) do
    Sidekiq::Worker.clear_all
    Idea.destroy_all
  end

  it "should create the correct number of jobs" do
    user = build(:user, :uid => '0000-0001-7857-2795')
    user.save

    expect {
      OrcidWorker.perform_async(user.uid)
    }.to change(OrcidWorker.jobs, :size).by(1)
  end

  it "should update the display name of the user" do
    user = create(:user, :uid => '0000-0001-7857-2795', :name => "John Doe")

    job = OrcidWorker.new
    job.perform(user.uid)

    expect(user.reload.nice_name).to eq("Albert Einstein")
  end
end
