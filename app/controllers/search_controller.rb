class SearchController < ApplicationController
  respond_to :json, :html

  def search

    if params[:query]
      client = Swiftype::Client.new
      @results = client.search('engine', params[:query], {:per_page => '10', :page => params[:page] || 1})

      @ideas = @results['ideas']
    elsif params[:tags]
      @tags  = params[:tags].split(",").collect(&:strip)
      @ideas = Idea.has_all_tags(@tags).paginate(:per_page => '10', :page => params[:page])
    end

    respond_with @ideas
  end
end
