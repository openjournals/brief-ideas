FactoryGirl.define do
  factory :idea do
    state       'published'
    body        'Cows are actually very large sheep that have been taught to make a different sound'
    subject     'Physics > Astrology'
    tags        ['Nuthin', 'Interesting']
    doi         'http://dx.doi.org/10.0001/zenodo.12345'
    vote_count  0
    created_at  { Time.now }
    updated_at  { Time.now }
    user
  end
end
