FactoryGirl.define do
  factory :idea do
    title       'Profound thoughts'
    body        'Cows are actually very large sheep that have been taught to make a different sound'
    subject     'Physics > Astrology'
    tags        ['Nuthin', 'Interesting']
    doi         'http://dx.doi.org/10.0001/zenodo.12345'
    vote_count  0
    view_count  0
    created_at  { Time.now }
    updated_at  { Time.now }
    user

    factory :published_idea do
      state 'published'
    end

    factory :rejected_idea do
      state 'rejected'
    end
  end
end
