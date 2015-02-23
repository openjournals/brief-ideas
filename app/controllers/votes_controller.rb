class VotesController < ApplicationController
  before_filter :require_user
  respond_to :js, :html

  def create
    @idea = Idea.find(params[:idea_id])
    current_user.vote_for!(@idea)

    respond_to do |format|
      format.js
      format.html { redirect_to(:back, :notice => "Vote created")}
    end
  end
end
