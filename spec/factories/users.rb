FactoryBot.define do
  factory :user do
    name { "田中太郎" }
    sequence(:email) { |n| "test#{n}@example.com" }
    password { "password" }
  end
end
