class AdminController < ApplicationController
  before_filter :require_admin_user

  def index
    @ideas = Idea.by_date.paginate(:page => params[:page], :per_page => 20)

    respond_to do |format|
      format.html
    end
  end

  def publish
    @idea = Idea.find_by_sha(params[:id])
    @idea.publish!
    redirect_to admin_index_url, :notice => "Idea published"
  end

  def mute
    @idea = Idea.find_by_sha(params[:id])
    @idea.mute!
    redirect_to admin_index_url, :notice => "Idea muted"
  end

  def reject
    @idea = Idea.find_by_sha(params[:id])
    @idea.reject!
    redirect_to admin_index_url, :notice => "Idea rejected"
  end

  def tweet
    @idea = Idea.find_by_sha(params[:id])
    @idea.tweet!
    redirect_to admin_index_url, :notice => "Idea tweeted"
  end
end
