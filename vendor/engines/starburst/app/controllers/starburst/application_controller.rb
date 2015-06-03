module Starburst
  class ApplicationController < ActionController::Base

    private
    helper_method :current_user

    def current_user
      if user = User.find_by_id(session[:user_id])
        return user
      else
        return false
      end
    end
  end
end
