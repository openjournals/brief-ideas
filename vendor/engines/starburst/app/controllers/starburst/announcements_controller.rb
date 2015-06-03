require_dependency 'starburst/application_controller'

module Starburst
	class AnnouncementsController < ApplicationController
		def mark_as_read
			announcement = Announcement.find(params[:id].to_i)

			if current_user && announcement
				if AnnouncementView.where(user_id: current_user.id, announcement_id: announcement.id).first_or_create(user_id: current_user.id, announcement_id: announcement.id)
					render :json => :ok
				else
					render json: nil, :status => :unprocessable_entity
				end
			else
				render json: nil, :status => :unprocessable_entity
			end
		end
	end
end
