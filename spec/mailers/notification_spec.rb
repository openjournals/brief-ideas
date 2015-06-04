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

  it "should notify submitting_author when new authors are added" do
    submitting_author = create(:user)
    idea = create(:idea, :title => "Nice idea!")
    idea.authors << submitting_author
    new_author = create(:user)
    idea.authors << new_author

    mail = Notification.authorship_email(idea, new_author)
    expect(mail.subject).to match /New author added/
  end

  it "should notify submitting_author when their ideas is rejected" do
    submitting_author = create(:user)
    idea = create(:idea, :title => "Nice idea!")
    idea.authors << submitting_author

    mail = Notification.rejection_email(idea)
    expect(mail.subject).to match /Your idea was rejected/
  end
end
