FactoryBot.define do
  factory :question_selection do
    association :user
    association :visit
    association :question
    selected_at { Time.current }
  end
end
