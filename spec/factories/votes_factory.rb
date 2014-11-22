FactoryGirl.define do
  factory :vote do
    user
    idea
    created_at  { Time.now }
    updated_at  { Time.now }
  end
end
