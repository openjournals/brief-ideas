class Notification < ActionMailer::Base
  default :from => "noreply@briefideas.org"

  EDITOR_EMAILS = ["physicsdavid@gmail.com", "arfon.smith@gmail.com"]
  SYSTEM_EMAILS = ["arfon.smith@gmail.com"]


  def submission_email(idea)
    @url  = "http://beta.briefideas.org/ideas/#{idea.sha}"
    @idea = idea
    mail(:to => EDITOR_EMAILS, :subject => "New submission: #{idea.title}")
  end

  def ratings_email
    mail(:to => SYSTEM_EMAILS, :subject => "Ratings updated")
  end

  def comment_email(comment)
    @url  = "http://beta.briefideas.org/ideas/#{comment.commentable.sha}"
    @comment = comment
    mail(:to => EDITOR_EMAILS, :subject => "New comment by #{comment.user.nice_name}")
  end

  def authorship_email(idea, user)
    @url  = "http://beta.briefideas.org/ideas/#{idea.sha}"
    @idea = idea
    @new_author = user
    mail(:to => idea.submitting_author.email, :subject => "New author added to #{idea.title}")
  end

  def rejection_email(idea)
    @url  = "http://beta.briefideas.org/ideas/#{idea.sha}"
    @idea = idea
    mail(:to => idea.submitting_author.email, :subject => "Your idea was rejected.")
  end

  def acceptance_email(idea)
    @url  = "http://beta.briefideas.org/ideas/#{idea.sha}"
    @idea = idea
    mail(:to => idea.submitting_author.email, :subject => "Your idea was accepted.")
  end
end
