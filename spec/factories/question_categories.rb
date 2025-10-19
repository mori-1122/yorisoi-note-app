FactoryBot.define do
  factory :question_category do
    sequence(:category_name) { |n| "カテゴリ#{n}" }

    trait :medicine do
      category_name { "薬" }
    end

    trait :lifestyle do
      category_name { "生活" }
    end
  end
end
