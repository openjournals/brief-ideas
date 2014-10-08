class IdeasController < ApplicationController
  before_filter :require_user

  def new
    @idea = Idea.new
  end

  def create
    @idea = Idea.new(idea_params)
    @idea.user = current_user

    if @idea.save
      redirect_to idea_path(@idea), :notice => "Idea created"
    else
      render :action => "edit"
    end
  end

  def show
    @idea = Idea.find_by_sha(params[:id])
  end

  private

  def idea_params
    params.require(:idea).permit(:title, :body)
  end
end
