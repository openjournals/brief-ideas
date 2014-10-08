class UsersController < ApplicationController
  def show
    @user = User.find_by_sha(params[:id])
  end
end
