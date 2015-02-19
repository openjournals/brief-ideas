class Notification < ActionMailer::Base
  default :from => "noreply@briefideas.org"

  EDITOR_EMAILS = ["physicsdavid@gmail.com", "arfon.smith@gmail.com"]

  def submission_email(idea)
    @url  = "http://beta.briefideas.org/ideas/#{idea.sha}"
    @idea = idea
    mail(:to => EDITOR_EMAILS, :subject => "New submission: #{idea.title}")
  end
end
