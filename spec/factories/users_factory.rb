FactoryGirl.define do
  factory :user do
    provider  'github'
    name  'John Doe'
    created_at  { Time.now }
    email 'john@apple.com'
    uid '0000-0000-0000-1234'

    factory :admin do
      admin true
    end
  end
end
