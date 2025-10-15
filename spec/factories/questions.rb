FactoryBot.define do
  factory :question do
    association :department
    association :question_category
    sequence(:content) { |n| "家で測った血圧が高めです#{n}" }

    # 診療科なし
    trait :without_department do
      department { nil }
    end

    # カテゴリなし
    trait :without_category do
      question_category { nil }
    end

    # 両方なし
    trait :without_both do
      department { nil }
      question_category { nil }
    end

    # 内科
    trait :internal_medicine do
      association :department, factory: [ :department, :internal_medicine ]
      content { "この症状はどのような病気の可能性がありますか？" }
    end

    # 外科
    trait :surgery do
      association :department, factory: [ :department, :surgery ]
      content { "痛みがあるのですが、どのような治療が必要ですか？" }
    end

    # 薬関連
    trait :about_medicine do
      association :question_category, factory: [ :question_category, :medicine ]
      content { "飲んでいる薬の副作用が心配です" }
    end

    # 検査関連
    trait :about_examination do
      association :question_category, factory: [ :question_category, :examination ]
      content { "検査の結果を詳しく教えてください" }
    end

    # 内科と薬
    trait :internal_medicine_about_medicine do
      association :department, factory: [ :department, :internal_medicine ]
      association :question_category, factory: [ :question_category, :medicine ]
      content { "内科で処方された薬について相談したいです" }
    end
  end
end
