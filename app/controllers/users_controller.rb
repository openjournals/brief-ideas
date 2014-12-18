class UsersController < ApplicationController
  respond_to :json, :html
  def show
    @user = User.find_by_sha(params[:id])
    @ideas = @user.ideas.paginate(:page => params[:page], :per_page => 10)
    respond_with @ideas
  end

  def lookup
    @results = User.fuzzy_search(params[:name]).limit(10)
    respond_with @results
  end
end
