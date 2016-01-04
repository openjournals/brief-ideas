class SearchController < ApplicationController
  respond_to :json, :html

  def search
    if params[:query]
      client = Swiftype::Client.new
      @results = client.search('engine', params[:query].downcase, {:per_page => '10', :page => params[:page] || 1})

      @ideas = @results['ideas']
    elsif params[:tags]
      @tags  = params[:tags].split(",").collect(&:strip).collect(&:downcase)
      @ideas = Idea.visible.has_all_tags(@tags).paginate(:per_page => '10', :page => params[:page])
    end

    respond_with @ideas
  end
end
