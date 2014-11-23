class SearchController < ApplicationController
  def search
    if params[:query]
      client = Swiftype::Client.new
      @results = client.search('engine', params[:query], {:per_page => '10', :page => params[:page] || 1})

      @ideas = @results['ideas']
    end
  end
end
