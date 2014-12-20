class UsersController < ApplicationController
  def show
    @user = User.find_by_sha(params[:id])
    @ideas = @user.ideas.paginate(:page => params[:page], :per_page => 10)
  end
end
