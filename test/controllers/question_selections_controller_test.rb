require "test_helper"

class QuestionSelectionsControllerTest < ActionDispatch::IntegrationTest
  test "should create question_selection" do
    # ユーザー作成（name が必要な場合を想定）
    user = User.create!(
      email: "test@example.com",
      password: "password",
      name: "テストユーザー"
    )

    # 診療科・カテゴリ作成
    department = Department.create!(name: "内科")
    question_category = QuestionCategory.create!(category_name: "薬")

    # 質問テンプレート作成
    question = Question.create!(
      content: "テスト質問",
      department: department,
      question_category: question_category
    )

    # 診察記録作成（Visit）
    visit = Visit.create!(
      user: user,
      department: department,
      hospital_name: "テスト病院",
      purpose: "検査",
      appointed_at: 1.day.from_now.change(hour: 9, min: 0),
      visit_date: 1.day.from_now.to_date
    )

    # POST リクエストで question_selection を作成
    post visit_question_selections_path(visit),
        params: {
          question_ids: [ question.id ]
        }

    # レスポンスがリダイレクトであることを確認
    assert_response :redirect
  end
end
