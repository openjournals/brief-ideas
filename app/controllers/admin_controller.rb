class AdminController < ApplicationController
  before_filter :require_admin_user

  def index
    @ideas = Idea.by_date.paginate(:page => params[:page], :per_page => 20)

    respond_to do |format|
      format.html
    end
  end

  def audits
    @idea = Idea.find_by_sha(params[:id])
  end

  def publish
    @idea = Idea.find_by_sha(params[:id])
    @idea.publish!
    audit('published', current_user)
    redirect_to admin_index_url, :notice => "Idea published"
  end

  def mute
    @idea = Idea.find_by_sha(params[:id])
    @idea.mute!
    audit('muted', current_user)
    redirect_to admin_index_url, :notice => "Idea muted"
  end

  def reject
    @idea = Idea.find_by_sha(params[:id])
    @idea.reject!
    audit('rejected', current_user)
    redirect_to admin_index_url, :notice => "Idea rejected"
  end

  def tweet
    @idea = Idea.find_by_sha(params[:id])
    @idea.tweet!
    audit('tweeted', current_user)
    redirect_to admin_index_url, :notice => "Idea tweeted"
  end

  def remove_comment
    @comment = Comment.find(params[:id])
    @idea = @comment.commentable
    @comment.destroy
    redirect_to idea_path(@idea), :warning => "Comment removed"
  end

protected

  def audit(action, user)
    @idea.audit_logs.create!(:user => current_user, :action => action)
  end
end
