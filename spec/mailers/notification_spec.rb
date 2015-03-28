require "rails_helper"

describe Notification, :type => :mailer do
  it "should include the idea text in the body" do
    idea = create(:idea, :title => "Nice idea!")
    mail = Notification.submission_email(idea)

    expect(mail.subject).to match /Nice idea/
  end

  it "should include the comment body in the email" do
    idea = create(:idea)
    comment = create(:comment, :title => "Hi Mum!", :commentable_id => idea.id, :commentable_type => "Idea")

    mail = Notification.comment_email(comment)
    expect(mail.subject).to eq("New comment by John Doe")
  end
end
