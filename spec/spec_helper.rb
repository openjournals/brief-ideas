# This file was generated by the `rails generate rspec:install` command. Conventionally, all
# specs live under a `spec` directory, which RSpec adds to the `$LOAD_PATH`.
# The generated `.rspec` file contains `--require spec_helper` which will cause this
# file to always be loaded, without a need to explicitly require it in any files.
#
# Given that it is always loaded, you are encouraged to keep this file as
# light-weight as possible. Requiring heavyweight dependencies from this file
# will add to the boot time of your test suite on EVERY test run, even for an
# individual file that may not need all of that loaded. Instead, consider making
# a separate helper file that requires the additional dependencies and performs
# the additional setup, and require it from the spec files that actually need it.
#
# The `.rspec` file also contains a few flags that are not defaults but that
# users commonly want.
#
# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration

require 'capybara/rspec'
require 'paperclip/matchers'

RSpec.configure do |config|

  config.include Paperclip::Shoulda::Matchers

  # rspec-expectations config goes here. You can use an alternate
  # assertion/expectation library such as wrong or the stdlib/minitest
  # assertions if you prefer.
  config.expect_with :rspec do |expectations|
    # This option will default to `true` in RSpec 4. It makes the `description`
    # and `failure_message` of custom matchers include text for helper methods
    # defined using `chain`, e.g.:
    # be_bigger_than(2).and_smaller_than(4).description
    #   # => "be bigger than 2 and smaller than 4"
    # ...rather than:
    #   # => "be bigger than 2"
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  # rspec-mocks config goes here. You can use an alternate test double
  # library (such as bogus or mocha) by changing the `mock_with` option here.
  config.mock_with :rspec do |mocks|
    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended, and will default to
    # `true` in RSpec 4.
    # GAAAAAHHHHH https://github.com/rspec/rspec-rails/issues/1076
    mocks.verify_partial_doubles = false
  end

# The settings below are suggested to provide a good initial experience
# with RSpec, but feel free to customize to your heart's content.
=begin
  # These two settings work together to allow you to limit a spec run
  # to individual examples or groups you care about by tagging them with
  # `:focus` metadata. When nothing is tagged with `:focus`, all examples
  # get run.
  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  # Limits the available syntax to the non-monkey patched syntax that is recommended.
  # For more details, see:
  #   - http://myronmars.to/n/dev-blog/2012/06/rspecs-new-expectation-syntax
  #   - http://teaisaweso.me/blog/2013/05/27/rspecs-new-message-expectation-syntax/
  #   - http://myronmars.to/n/dev-blog/2014/05/notable-changes-in-rspec-3#new__config_option_to_disable_rspeccore_monkey_patching
  config.disable_monkey_patching!

  # Many RSpec users commonly either run the entire suite or an individual
  # file, and it's useful to allow more verbose output when running an
  # individual spec file.
  if config.files_to_run.one?
    # Use the documentation formatter for detailed output,
    # unless a formatter has already been configured
    # (e.g. via a command-line flag).
    config.default_formatter = 'doc'
  end

  # Print the 10 slowest examples and example groups at the
  # end of the spec run, to help surface which specs are running
  # particularly slow.
  config.profile_examples = 10

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = :random

  # Seed global randomization in this process using the `--seed` CLI option.
  # Setting this allows you to use `--seed` to deterministically reproduce
  # test failures related to randomization by passing the same `--seed` value
  # as the one that triggered the failure.
  Kernel.srand config.seed
=end
end

require 'webmock/rspec'
WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |config|
  config.before(:each) do
    Sidekiq::Worker.clear_all

    # ORCID username retrieval
    stub_request(:get, "https://pub.orcid.org/v2.1/0000-0001-7857-2795").
         with(:headers => {'Accept'=>'application/orcid+json', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).
         to_return(:status => 200, :body =>
           '{"orcid-identifier" : {"uri" : "https://orcid.org/0000-0002-3957-2474", "path" : "0000-0002-3957-2474", "host" : "orcid.org"},"person" : {"name" : {"created-date" : {"value" : 1460758938409},"last-modified-date" : {"value" : 1460758938409},"given-names" : {"value" : "Albert"},"family-name" : {"value" : "Einstein"},"credit-name" : null,"source" : null,"visibility" : "PUBLIC","path" : "0000-0002-3957-2474"}}}', :headers => {})


    # Zenodo create_deposit
    stub_request(:post, "https://sandbox.zenodo.org/api/deposit/depositions?access_token=0000-0000-0000-0000-0000-0000-0000").
      with(:body => '{"metadata":{"title":"Profound thoughts","upload_type":"publication","publication_type":"article","description":"A brief idea","creators":[{"name":"Doe, John","affiliation":"","orcid":"0000-0000-0000-1234"}],"keywords":["Nuthin","Interesting"],"communities":[{"identifier":"briefideas"}],"license":"cc-by","related_identifiers":[{"relation":"isIdenticalTo","identifier":"http://beta.briefideas.org/ideas/48d24b0158528e85ac7706aecd8cddc4"}]}}',
           :headers => {'Accept'=>'application/json', 'Accept-Encoding'=>'gzip, deflate', 'Content-Length'=>'441', 'Content-Type'=>'application/json', 'User-Agent'=>'Ruby'}).
      to_return(:status => 201, :body => '{"files": [], "created": "2014-11-25T03:05:43+00:00", "title": "Someting", "modified": "2014-11-25T03:05:43+00:00", "submitted": false, "state": "inprogress", "owner": 10, "id": 77, "metadata": {"embargo_date": null, "partof_title": null, "journal_volume": null, "grants": [], "references": [], "keywords": [], "publication_type": "article", "imprint_publisher": null, "title": "Someting", "image_type": "", "partof_pages": null, "imprint_isbn": null, "thesis_supervisors": [], "conference_url": null, "imprint_place": null, "journal_issue": null, "access_right": "open", "conference_acronym": null, "conference_title": null, "description": "<p>This is what 200 words looks like: Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum orci orci, lacinia a sagittis et, elementum ac eros. Ut ac posuere justo. Nunc nec libero vitae erat lacinia dapibus vel mollis ipsum. Integer tempor est quis eros eleifend tempus. Fusce sed orci vitae sapien blandit venenatis non nec nunc. Maecenas quam sapien, porttitor sit amet volutpat vitae, pharetra vel sem. Nullam vulputate libero accumsan porta ultricies. Praesent tortor mi, tempus quis odio sed, aliquet posuere magna. Etiam eget tellus id dui molestie imperdiet. Pellentesque vulputate, enim a pretium maximus, mauris ex viverra lectus, non consectetur enim ante at mauris. Mauris varius, mauris id varius varius, urna mi fringilla velit, quis bibendum leo justo sed justo. Etiam tincidunt turpis vestibulum justo vulputate iaculis. Vivamus tristique lacus at lorem molestie tempus. Pellentesque commodo laoreet lorem non ultrices. Morbi in imperdiet risus. Phasellus efficitur euismod felis at volutpat. Suspendisse viverra, dolor non volutpat fringilla, lorem risus accumsan quam, eget tempor ipsum nunc a purus. Sed tincidunt venenatis ante non feugiat. Nunc mattis risus at sapien eleifend, id iaculis orci dignissim. Suspendisse elementum nibh eget velit semper egestas. Suspendisse feugiat lorem eget urna laoreet, vel iaculis arcu.</p>", "journal_title": null, "upload_type": "publication", "prereserve_doi": null, "communities": [], "publication_date": "2014-11-25", "conference_place": null, "conference_session_part": null, "doi": "", "license": "cc-by", "notes": "", "journal_pages": null, "conference_dates": null, "creators": [{"orcid": "0000-0002-3957-2474", "affiliation": "", "name": "Smith, Arfon"}], "conference_session": null, "related_identifiers": []}}', :headers => {})

    # Zenodo upload_files
    stub_request(:post, "https://sandbox.zenodo.org/api/deposit/depositions/77/files?access_token=0000-0000-0000-0000-0000-0000-0000").
      with(:body => hash_including(),
           :headers => {"Content-Type" => /multipart\/.+/}).
      to_return(:status => 201, :body => '{"id": "46d1420a-eacf-49bb-b97b-1ad36db4f419", "checksum": "b8b614f313a43589326deeb2821ccfcb", "filesize": "14", "filename": "unicorn.txt"}', :headers => {})

    # Zenodo publish!
    stub_request(:post, "https://sandbox.zenodo.org/api/deposit/depositions/77/actions/publish?access_token=0000-0000-0000-0000-0000-0000-0000").
      with(:headers => {'Accept'=>'application/json', 'Accept-Encoding'=>'gzip, deflate', 'Content-Length'=>'0', 'Content-Type'=>'application/json', 'User-Agent'=>'Ruby'}).
      to_return(:status => 202, :body => '{"files": [{"id": "46d1420a-eacf-49bb-b97b-1ad36db4f419", "checksum": "b8b614f313a43589326deeb2821ccfcb", "filesize": "14", "filename": "unicorn.txt"}], "created": "2014-11-25T13:36:32+00:00", "title": "Blank", "modified": "2014-11-25T13:38:39+00:00", "submitted": true, "state": "done", "owner": 10, "id": 78, "metadata": {"embargo_date": null, "partof_title": null, "journal_volume": null, "grants": [], "references": [], "keywords": ["Arfon"], "publication_type": "article", "title": "Blank", "image_type": "", "partof_pages": null, "conference_url": null, "thesis_supervisors": [], "imprint_isbn": null, "imprint_place": null, "journal_issue": null, "access_right": "open", "conference_acronym": null, "conference_title": null, "description": "<p>HAHHA</p>", "journal_title": null, "upload_type": "publication", "communities": [], "publication_date": "2014-11-25", "conference_place": null, "creators": [{"orcid": "0000-0002-3957-2474", "affiliation": "", "name": "Smith, Arfon"}], "conference_session_part": null, "doi": "10.5072/zenodo.31", "license": "cc-by", "notes": "", "journal_pages": null, "conference_dates": null, "imprint_publisher": null, "conference_session": null, "related_identifiers": []}, "record_id": 31, "record_url": "https://dev.zenodo.org/record/31", "doi": "10.5072/zenodo.31", "doi_url": "http://dx.doi.org/10.5072/zenodo.31"}', :headers => {})
  end
end

def hash_from_json(json)
  return JSON.parse(json)
end

def cite(idea, citing_idea)
  citing_idea.idea_references.create(:referenced_id => idea.id)
end
