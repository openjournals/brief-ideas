class ZenodoWorker
  include Sidekiq::Worker

  def perform(idea_id)
    idea = Idea.find_by_sha(idea_id)

    create_deposit(idea)
    upload_files(idea)

    # Mark as published
    publish!(idea)
  end

  def create_deposit(idea)
    RestClient.post("#{Rails.configuration.zenodo_url}/api/deposit/depositions?access_token=#{Rails.configuration.zenodo_token}", deposit_params(idea), :content_type => :json, :accept => :json){ |response, request, result, &block|
      case response.code
      when 201
        zenodo_response = JSON.parse(response.body)
        idea.update_attribute(:zenodo_id, zenodo_response['id'])
        puts "CREATED ZENODO DEPOSIT FOR #{idea.sha}, ZENODO ID #{zenodo_response['id']}"
      else
        response.return!(request, result, &block)
      end
    }
  end

  def deposit_params(idea)
    {
      :metadata => {
        :title => idea.title,
        :upload_type => "publication",
        :publication_type => "article",
        :description => idea.formatted_body,
        :creators => [{:name => idea.user.name, :affiliation => ""}]
      }
    }.to_json
  end

  def upload_files(idea)
    RestClient.post("#{Rails.configuration.zenodo_url}/api/deposit/depositions/#{idea.zenodo_id}/files?access_token=#{Rails.configuration.zenodo_token}", { :file => File.new("#{Rails.root}/app/assets/images/unicorn.jpg", 'rb'), :name => "unicorn.jpg", :multipart => true}){ |response, request, result, &block|
      case response.code
      when 201
        zenodo_response = JSON.parse(response.body)
        puts "UPLOADED FILES FOR #{idea.sha}, ZENODO ID #{zenodo_response['id']}"
      else
        response.return!(request, result, &block)
      end
    }
  end

  def publish!(idea)
    RestClient.post("#{Rails.configuration.zenodo_url}/api/deposit/depositions/#{idea.zenodo_id}/actions/publish?access_token=#{Rails.configuration.zenodo_token}", "", :content_type => :json, :accept => :json){ |response, request, result, &block|
      case response.code
      when 202
        zenodo_response = JSON.parse(response.body)
        idea.update_attribute(:doi, zenodo_response['doi_url'])
        puts "PUBLISHED! #{idea.sha}"
      else
        response.return!(request, result, &block)
      end
    }
  end
end
