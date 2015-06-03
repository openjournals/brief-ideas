module Starburst
  module AnnouncementsHelper

    def current_announcement
      @current_announcement ||= Announcement.current(current_user)
    end
  end
end
