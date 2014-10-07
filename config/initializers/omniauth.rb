Rails.application.config.middleware.use OmniAuth::Builder do
  provider :github, ENV['OCTOKIT_CLIENT_ID'], ENV['OCTOKIT_CLIENT_SECRET'], scope: "user,gist"
end
