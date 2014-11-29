class ZenodoWorker
  include Sidekiq::Worker

  def perform(idea_id)
    idea = Idea.find_by_sha(idea_id)

    create_deposit(idea)
    upload_files(idea)

    # Mark as published
    publish!(idea)

    # Insert into Swiftype index
    create_document(idea)
  end

  def create_deposit(idea)
    RestClient.post("#{Rails.configuration.zenodo_url}/api/deposit/depositions?access_token=#{Rails.configuration.zenodo_token}", deposit_params(idea), :content_type => :json, :accept => :json){ |response, request, result, &block|
      case response.code
      when 201
        zenodo_response = JSON.parse(response.body)
        idea.update_attribute(:zenodo_id, zenodo_response['id'])
        Rails.logger.info "CREATED ZENODO DEPOSIT FOR #{idea.sha}, ZENODO ID #{zenodo_response['id']}"
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
        :creators => [{:name => idea.user.name, :affiliation => "", :orcid => idea.user.uid}],
        :keywords => [idea.zenodo_keywords],
        :license => "cc-by"
      }
    }.to_json
  end

  def upload_files(idea)
    RestClient.post("#{Rails.configuration.zenodo_url}/api/deposit/depositions/#{idea.zenodo_id}/files?access_token=#{Rails.configuration.zenodo_token}", { :file => File.new("#{Rails.root}/test/fixtures/unicorn.txt", 'rb'), :name => "unicorn.txt", :multipart => true}){ |response, request, result, &block|
      case response.code
      when 201
        zenodo_response = JSON.parse(response.body)
        Rails.logger.info "UPLOADED FILES FOR #{idea.sha}, ZENODO ID #{zenodo_response['id']}"
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
        Rails.logger.info "PUBLISHED! #{idea.sha}"
      else
        response.return!(request, result, &block)
      end
    }
  end

  def create_document(idea)
    client = Swiftype::Client.new
    document = client.create_document('engine', 'ideas', {
                :external_id => idea.sha,
                :fields => [
                  {:name => 'title', :value => idea.title, :type => 'string'},
                  {:name => 'doi', :value => idea.doi, :type => 'enum'},
                  {:name => 'body', :value => idea.body, :type => 'text'},
                  {:name => 'subject', :value => idea.subject, :type => 'text'},
                  {:name => 'author', :value => idea.user.name, :type => 'text'},
                  {:name => 'tags', :value => idea.formatted_tags, :type => 'string'},
                  {:name => 'ordid_id', :value => idea.user.uid, :type => 'string'}
                  ]})
    Rails.logger.info "UPLOADING TO INDEX! #{idea.sha}"
  end
end
