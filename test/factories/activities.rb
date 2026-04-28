FactoryBot.define do
  factory :activity do
    association :user
    name   { Faker::Hobby.activity.slice(0, 20) }
    active { true }
  end
end
