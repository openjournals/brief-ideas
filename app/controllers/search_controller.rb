class SearchController < ApplicationController
  respond_to :json, :html

  def search
    if params[:tags]
      @tags  = params[:tags].split(",").collect(&:strip).collect(&:downcase)
      @ideas = Idea.visible.has_all_tags(@tags).paginate(:per_page => '10', :page => params[:page])
    end

    respond_with @ideas
  end
end
