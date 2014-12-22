class UsersController < ApplicationController
  respond_to :json, :html
  def show
    @user = User.find_by_sha(params[:id])
    @ideas = @user.ideas.paginate(:page => params[:page], :per_page => 10)
    respond_with @ideas
  end

  def lookup
    @users = User.fuzzy_search(params[:query]).limit(10)
    respond_with @users.as_json(:methods => [:nice_name])
  end
end
