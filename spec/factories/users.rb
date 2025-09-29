FactoryBot.define do
  factory :user do
    name { "田中太郎" }
    email { "test@example.com" }
    password { "password" }
  end
end
