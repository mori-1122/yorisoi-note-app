FactoryBot.define do
  factory :visit do
    association :user
    association :department

    visit_date { Date.tomorrow }
    hospital_name { "東京病院" }
    purpose { "検査" }
    appointed_at { 1.hour.from_now }
  end
end
