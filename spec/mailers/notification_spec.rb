require "rails_helper"

describe Notification, :type => :mailer do
  it "should include the idea text in the body" do
    idea = create(:idea, :title => "Nice idea!")
    mail = Notification.submission_email(idea)

    expect(mail.subject).to match /Nice idea/
  end
end
