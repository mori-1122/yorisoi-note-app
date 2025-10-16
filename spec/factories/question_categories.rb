FactoryBot.define do
  factory :question_category do
    sequence(:category_name) { |n| "カテゴリ#{n}" }
  end
end
