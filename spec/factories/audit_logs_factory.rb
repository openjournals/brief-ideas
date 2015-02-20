FactoryGirl.define do
  factory :audit_log do
    idea
    user
    title 'Action taken'

    factory :mute_audit_log do
      action 'muted'
    end

    factory :reject_audit_log do
      action 'rejected'
    end

    factory :publish_audit_log do
      action 'published'
    end

    factory :tweet_audit_log do
      action 'tweeted'
    end
  end
end
