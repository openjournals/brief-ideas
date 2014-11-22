class VotesController < ApplicationController
  before_filter :require_user
  respond_to :js

  def create
    @idea = Idea.find(params[:idea_id])
    current_user.vote_for!(@idea)
  end
end
