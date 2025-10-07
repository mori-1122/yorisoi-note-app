FactoryBot.define do
  factory :notification do
    association :user
    association :visit
    title { "テスト通知" }
    due_date { Date.today }
    is_sent { false }
  end
end
