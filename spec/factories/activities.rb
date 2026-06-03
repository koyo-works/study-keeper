FactoryBot.define do
  factory :activity do
    association :user
    sequence(:name) { |n| "Activity #{n}" }
    active { true }
  end
end
