FactoryBot.define do
  factory :weekly_goal do
    association :user
    association :activity
    percentage { 50 }
    week_start { Date.current.beginning_of_week(:monday) }
  end
end
