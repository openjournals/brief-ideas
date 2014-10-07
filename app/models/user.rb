class User < ActiveRecord::Base
  def self.from_omniauth(auth)
    where(:provider => auth.provider, :uid => auth.uid).first_or_create do |user|
      user.provider = auth.provider
      user.uid      = auth.uid
      user.name     = auth.info.name
      user.avatar_url = auth.info.image
      user.extra = auth
      user.email = auth.info.email
      user.oauth_token = auth.credentials.token
      user.oauth_expires_at = Time.at(auth.credentials.expires_at) if auth["provider"] == "facebook"
      user.save
    end
  end
end
