FactoryGirl.define do
  factory :idea_reference do
    idea_id       { idea }
    referenced_id { idea }
    created_at    { Time.now }
    updated_at    { Time.now }
  end
end
