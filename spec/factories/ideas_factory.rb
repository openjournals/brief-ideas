FactoryGirl.define do
  factory :idea do
    state       'published'
    body        'Cows are actually very large sheep that have been taught to make a different sound'
    vote_count  0
    created_at  { Time.now }
    updated_at  { Time.now }
    user
  end
end
