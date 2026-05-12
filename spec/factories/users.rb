FactoryBot.define do
  factory :user do
    name     { Faker::Name.name.slice(0, 20) }
    email    { Faker::Internet.unique.email }
    password { 'password123' }
  end
end
