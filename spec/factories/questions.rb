FactoryBot.define do
  factory :question do
    association :department
    association :question_category
    content { "家で測った血圧が高めです" }
  end
end
