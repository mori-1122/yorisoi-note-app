FactoryBot.define do
  factory :profile do
    association :user
    birthday { Date.new(1985, 1, 1) }
    gender { :male }
    height { 180 }
    weight { 80 }
    
    trait :no_blood_type do
      blood_type { nil }
    end
  end
end
