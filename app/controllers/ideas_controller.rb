class IdeasController < ApplicationController
  before_filter :require_user, :except => [ :preview, :show ]

  def new
    @idea = Idea.new
  end

  def create
    @idea = Idea.new(idea_params)
    @idea.tags = idea_params['tags'].split(',').collect(&:strip)
    @idea.user = current_user

    if @idea.save
      redirect_to idea_path(@idea), :notice => "Idea created"
    else
      render :action => "edit"
    end
  end

  def preview
    filter = HTML::Pipeline::MarkdownFilter.new(params[:idea])
    render :text => filter.call
  end

  def show
    @idea = Idea.find_by_sha(params[:id])
  end

  private

  def idea_params
    params.require(:idea).permit(:title, :body, :subject, :tags)
  end
end
