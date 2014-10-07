OCTOKIT_CLIENT = Octokit::Client.new(
  :client_id     => ENV['OCTOKIT_CLIENT_ID'],
  :client_secret => ENV['OCTOKIT_CLIENT_SECRET']
)
