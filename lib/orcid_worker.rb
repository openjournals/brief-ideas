require 'open-uri'

class OrcidWorker
  include Sidekiq::Worker

  def perform(orcid_id)
    user = User.find_by_uid(orcid_id)
    name = orcid_name_for(orcid_id)
    user.update_attributes(:name => name)
  end

  def orcid_name_for(orcid_id)
    data = JSON.parse(open("https://pub.orcid.org/v2.1/#{orcid_id}", "Accept" => "application/orcid+json").read)
    given_name = data['person']['name']['given-names']['value']
    if data['person']['name'].has_key?('family-name')
      surname = data['person']['name']['family-name']['value']
      return "#{surname}, #{given_name}"
    else
      return "#{given_name}"
    end
  end
end
