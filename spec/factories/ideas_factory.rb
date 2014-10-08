FactoryGirl.define do
  factory :idea do
    state       'published'
    body        'Cows are actually very large sheep that have been taught to make a different sound'
    created_at  { Time.now }
    updated_at  { Time.now }
    user
  end
end
