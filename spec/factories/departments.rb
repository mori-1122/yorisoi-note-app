FactoryBot.define do
  factory :department do
    sequence(:name) { |n| "診療科#{n}" }

    trait :internal_medicine do
      name { "内科" }
    end

    trait :surgery do
      name { "外科" }
    end
  end
end
