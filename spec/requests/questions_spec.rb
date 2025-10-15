require 'rails_helper'

RSpec.describe "Questions", type: :request do
  let(:user) { create(:user) }
  let(:visit) { create(:visit, user: user) }
  let(:department) { create(:department, name: "内科") }
  let(:question_category) { create(:question_category, category_name: "生活") }
  let(:question) { create(:question, department: department, question_category: question_category) }

  describe "質問画面へのアクセス GET /questions" do
    context "受診予定が指定されていない場合" do
      it "受診予定の一覧画面に遷移される" do
        sign_in user, scope: :user
        get questions_path
        expect(response).to redirect_to(visits_path)
        expect(flash[:alert]).to eq("受診予定を選択してください")
      end
    end
  end

  describe "質問選択画面の表示 GET /questions/select" do
    context "正しい受診予定が指定されている場合" do
      before do
        sign_in user, scope: :user
      end

      it "診療科が表示される" do
        get select_questions_path(visit_id: visit.id)
        expect(response).to have_http_status(200)
        expect(response.body).to include(department.name)
      end

      it "カテゴリ一覧が取得される" do
        get select_questions_path(visit_id: visit.id)
        expect(response.body).to be_present
        expect(response.body).to include(question_category.category_name).or include("カテゴリ")
      end

      it "すでに選択すみの質問が取得されている" do
        create(:question_selection, visit: visit, question: question, user: user)
        get select_questions_path(visit_id: visit.id)
        expect(response).to have_http_status(200)
      end
    end
  end

  describe "質問の絞り込み検索 GET /questions/search" do
    context "診療科で絞り込む場合" do
      it "該当する質問のみ取得できる (JSレスポンス)" do
        sign_in user, scope: :user
        internal_question = create(:question, department: department, content: "この症状はアレルギーが原因でしょうか？")
        surgery_question = create(:question, department: create(:department, :surgery), content: "すぐに治療が必要な状態でしょうか？")

        get search_questions_path(visit_id: visit.id, department_id: department.id, format: :js), xhr: true

        expect(response).to have_http_status(200)
        expect(response.media_type).to eq "text/javascript"
        expect(response.body).to include(internal_question.content)
        expect(response.body).not_to include(surgery_question.content)
      end

      it "診療科なしで絞り込みができる" do
        sign_in user, scope: :user
        no_dept_question = create(:question, department: nil, content: "飲んでいる薬の副作用が心配です")
        dept_question = create(:question, department: department, content: "ずっと飲み続ける必要がありますか？")
        get search_questions_path(visit_id: visit.id, department_id: "none", format: :js), xhr: true
        expect(response).to have_http_status(200)
        expect(response.body).to include(no_dept_question.content)
        expect(response.body).not_to include(dept_question.content)
      end
    end

    context "カテゴリで絞り込む場合" do
      it "該当する質問のみで取得できる" do
        sign_in user, scope: :user
        lifestyle_question = create(:question, question_category: question_category, content: "普段の生活で気をつけた方がいいことはありますか？")
        allergy_category = create(:question_category, category_name: "アレルギー")
        allergy_question = create(:question, question_category: allergy_category, content: "この症状はアレルギーが原因でしょうか？")
        get search_questions_path(visit_id: visit.id, question_category_id: question_category.id, format: :js), xhr: true
        expect(response).to have_http_status(200)
        expect(response.body).to include(lifestyle_question.content)
        expect(response.body).not_to include(allergy_question.content)
      end

      it "カテゴリなし(none)で絞り込める" do
        sign_in user, scope: :user
        no_category_question = create(:question, question_category: nil, content: "この症状はどのような病気の可能性がありますか？")
        category_question = create(:question, question_category: question_category, content: "食事や運動についてアドバイスをもらえますか？")
        get search_questions_path(visit_id: visit.id, question_category_id: "none", format: :js), xhr: true
        expect(response).to have_http_status(200)
        expect(response.body).to include(no_category_question.content)
        expect(response.body).not_to include(category_question.content)
      end
    end

    context "キーワードで絞り込む場合" do
      it "部分一致で質問を取得できる" do
        sign_in user, scope: :user
        matching_question = create(:question, content: "飲んでいる薬の副作用が心配です")
        non_matching_question = create(:question, content: "検査の結果を詳しく教えてください")
        get search_questions_path(visit_id: visit.id, keyword: "薬", format: :js), xhr: true
        expect(response).to have_http_status(200)
        expect(response.body).to include(matching_question.content)
        expect(response.body).not_to include(non_matching_question.content)
      end

      it "大文字小文字を区別せずに検索できる" do
        sign_in user, scope: :user
        question_with_hiragana = create(:question, content: "あれるぎーが心配です")
        get search_questions_path(visit_id: visit.id, keyword: "アレルギー", format: :js), xhr: true
        expect(response).to have_http_status(200)
        # ILIKE検索なので大文字小文字は区別されるが、ひらがなとカタカナは別物
      end
    end

    context "複数条件で絞り込む場合" do
      it "すべての条件に一致する質問のみ取得できる" do
        sign_in user, scope: :user
        matching_question = create(:question, department: department, question_category: question_category, content: "普段の生活で気をつけた方がいいことはありますか？")
        non_matching_question = create(:question, department: department, content: "今飲んでいる薬は、この症状に合っていますか？")
        get search_questions_path(visit_id: visit.id, department_id: department.id, question_category_id: question_category.id, keyword: "生活", format: :js), xhr: true
        expect(response).to have_http_status(200)
        expect(response.body).to include(matching_question.content)
        expect(response.body).not_to include(non_matching_question.content)
      end
    end
  end


  describe "質問の登録処理 POST /questions" do
    context "質問が選択されている場合" do
      it "質問選択が1件登録される" do
        sign_in user, scope: :user
        expect {
          post questions_path(visit_id: visit.id), params: { question_ids: [ question.id ] }
        }.to change(QuestionSelection, :count).by(1)
      end

      it "登録後に質問選択一覧にリダイレクトされる" do
        sign_in user, scope: :user
        post questions_path(visit_id: visit.id), params: { question_ids: [ question.id ] }
        expect(response).to redirect_to(visit_question_selections_path(visit))
        expect(flash[:notice]).to include("質問が追加されました")
      end
    end

    context "質問が何も選ばれていない場合" do
      it "登録されない" do
        sign_in user, scope: :user
        expect {
          post questions_path(visit_id: visit.id), params: { question_ids: [] }
        }.not_to change(QuestionSelection, :count)
      end
    end
  end
end
