class ZenodoWorker
  include Sidekiq::Worker

  def perform(idea_id)
    idea = Idea.find_by_sha(idea_id)

    create_deposit(idea)
    upload_body_file(idea)
    upload_attachments(idea)

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

  # Write out the idea body to a markdown file
  def upload_body_file(idea)
    # First write out a temp file with the idea contents
    File.open("#{Rails.root}/tmp/#{idea.sha}.md", "w") {|f| f.write(idea.body.to_s) }

    RestClient.post("#{Rails.configuration.zenodo_url}/api/deposit/depositions/#{idea.zenodo_id}/files?access_token=#{Rails.configuration.zenodo_token}", { :file => File.new("#{Rails.root}/tmp/#{idea.sha}.md"), :name => "#{idea.sha}.md", :multipart => true}){ |response, request, result, &block|
      case response.code
      when 201
        zenodo_response = JSON.parse(response.body)
        Rails.logger.info "UPLOADED FILES FOR #{idea.sha}, ZENODO ID #{zenodo_response['id']}"
      else
        response.return!(request, result, &block)
      end
    }
  end

  # In the future we might have more than one attachment
  def upload_attachments(idea)
    return unless idea.attachment.exists?
    attachment = idea.attachment

    # Grab file from S3
    tmp_file = open(attachment.url)

    # Write file to tmp
    File.open("#{Rails.root}/tmp/#{idea.sha}-#{attachment.original_filename}", "wb") {|f| f.write(tmp_file.read) }

    RestClient.post("#{Rails.configuration.zenodo_url}/api/deposit/depositions/#{idea.zenodo_id}/files?access_token=#{Rails.configuration.zenodo_token}", { :file => File.new("#{Rails.root}/tmp/#{idea.sha}-#{attachment.original_filename}"), :name => attachment.original_filename, :multipart => true}){ |response, request, result, &block|
      case response.code
      when 201
        zenodo_response = JSON.parse(response.body)
        Rails.logger.info "UPLOADED FILES FOR #{idea.sha}, ZENODO ID #{zenodo_response['id']}"
      else
        response.return!(request, result, &block)
      end
    }
  end

  def authors(idea)
    authors = []
    idea.authors.each do |author|
      authors << {:name => author.name, :affiliation => "", :orcid => author.uid}
    end

    return authors
  end

  def deposit_params(idea)
    {
      :metadata => {
        :title => idea.title,
        :upload_type => "publication",
        :publication_type => "article",
        :description => "A brief idea",
        :creators => authors(idea),
        :keywords => idea.tags,
        :communities => [{:identifier => "briefideas"}],
        :license => "cc-by",
        :related_identifiers => [{:relation => "isIdenticalTo", :identifier => "http://beta.briefideas.org/ideas/#{idea.sha}"}]
      }
    }.to_json
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

  # TODO: Check that dropping orcid id from fields doesn't cause errors
  def create_document(idea)
    client = Swiftype::Client.new
    document = client.create_document('engine', 'ideas', {
                :external_id => idea.sha,
                :fields => [
                  {:name => 'title', :value => idea.title, :type => 'string'},
                  {:name => 'doi', :value => idea.doi, :type => 'enum'},
                  {:name => 'body', :value => idea.body, :type => 'text'},
                  {:name => 'author', :value => idea.formatted_creators, :type => 'text'},
                  {:name => 'tags', :value => idea.formatted_tags, :type => 'string'},
                  ]})
    Rails.logger.info "UPLOADING TO INDEX! #{idea.sha}"
  end
end
