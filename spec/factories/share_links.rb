FactoryBot.define do
  factory :share_link do
    association :user
    share_type  { :daily }
    target_date { Date.current }
  end
end
