FactoryGirl.define do
  factory :comment do
    comment  'Yeah boyeee!'
    created_at  { Time.now }
    user
  end
end
