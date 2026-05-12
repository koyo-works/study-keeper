FactoryBot.define do
  factory :record do
    association :user
    association :activity
    logged_at { Time.current }
    ended_at  { Time.current + 30.minutes }
    memo      { nil }
  end
end
