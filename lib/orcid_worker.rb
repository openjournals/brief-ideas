require 'open-uri'

class OrcidWorker
  include Sidekiq::Worker

  def perform(orcid_id)
    user = User.find_by_uid(orcid_id)
    name = orcid_name_for(orcid_id)
    user.update_attributes(:name => name)
  end

  def orcid_name_for(orcid_id)
    data = JSON.parse(open("http://pub.orcid.org/v1.1/#{orcid_id}/orcid-bio", "Accept" => "application/orcid+json").read)
    given_name = data['orcid-profile']['orcid-bio']['personal-details']['given-names']['value']
    if data['orcid-profile']['orcid-bio']['personal-details'].has_key?('family-name')
      surname = data['orcid-profile']['orcid-bio']['personal-details']['family-name']['value']
      return "#{surname}, #{given_name}"
    else
      return "#{given_name}"
    end
  end
end
