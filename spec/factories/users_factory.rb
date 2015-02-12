FactoryGirl.define do
  factory :user do
    provider  'orcid'
    name  'Doe, John'
    created_at  { Time.now }
    email 'john@apple.com'
    uid '0000-0000-0000-1234'

    factory :admin_user do
      admin true
    end
  end
end
