FactoryGirl.define do
  factory :user do
    provider  'github'
    name  'John Doe'
    created_at  { Time.now }
    email 'john@apple.com'

    factory :admin do
      admin true
    end
  end
end
