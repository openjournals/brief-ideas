class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # Announcements
  helper Starburst::AnnouncementsHelper

  def require_user
    unless current_user
      redirect_to '/sessions/new', :notice => "Please log in"
    end
  end

  def require_admin_user
    redirect_to '/sessions/new' unless (current_user && current_user.admin?)
  end

  private

  def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
  helper_method :current_user
end
