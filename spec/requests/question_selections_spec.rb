require 'rails_helper'

RSpec.describe "QuestionSelections", type: :request do
  let(:user) { create(:user) }
  let(:visit) { create(:visit, user: user) }
  let(:department) { create(:department) }
  let(:question_category) { create(:question_category) }
  let(:question) { create(:question, department: department, question_category: question_category) }

  describe "GET /visits/:visit_id/question_selections" do
    context "ユーザーが質問を選ぶ画面を開いた場合" do
      it "質問選択画面を表示できる" do
        sign_in user, scope: :user
        get visit_question_selections_path(visit, page: "select")

        expect(response).to have_http_status(200)
        expect(response.body).to include("受診時に聞きたい質問を確認しましょう")
      end

      it "診療科とカテゴリが表示される" do
        sign_in user, scope: :user
        department
        question_category

        get visit_question_selections_path(visit, page: "select")

        expect(response).to have_http_status(200)
        expect(response.body).to include("受診時に聞きたい質問を確認しましょう")
      end

      it "質問の絞り込みができる" do
        sign_in user, scope: :user
        question1 = create(:question, content: "頭痛について", department: department)
        question2 = create(:question, content: "めまいについて")

        get visit_question_selections_path(visit, page: "select", department_id: department.id)
        expect(response).to have_http_status(200)
      end

      it "キーワード検索ができる" do
        sign_in user, scope: :user
        question1 = create(:question, content: "頭痛の原因")
        question2 = create(:question, content: "腹痛の対処法")

        get visit_question_selections_path(visit, page: "select", keyword: "頭痛")
        expect(response).to have_http_status(200)
      end

      it "JSON形式でレスポンスを返す" do
        sign_in user, scope: :user
        question
        selected_question = create(:question)
        create(:question_selection, visit: visit, question: selected_question, user: user)

        get visit_question_selections_path(visit, page: "select", format: :json)

        expect(response).to have_http_status(200)
        json = JSON.parse(response.body)
        expect(json["questions"]).to be_an(Array)
        expect(json["selected_ids"]).to include(selected_question.id)
      end
    end

    context "質問一覧画面を表示する場合" do
      it "選択済み質問の一覧を表示できる" do
        sign_in user, scope: :user
        question_selection = create(:question_selection, visit: visit, question: question, user: user)

        get visit_question_selections_path(visit, page: "list")

        expect(response).to have_http_status(200)
        expect(response.body).to include(question.content)
      end

      it "質問の総数が表示される" do
        sign_in user, scope: :user
        3.times do |i|
          q = create(:question, content: "質問#{i+1}")
          create(:question_selection, visit: visit, question: q, user: user)
        end

        get visit_question_selections_path(visit, page: "list")

        expect(response.body).to include("3")
      end
    end

    context "ログインしていない場合" do
      it "ログインページにリダイレクトされる" do
        get visit_question_selections_path(visit)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "POST /visits/:visit_id/question_selections" do
    context "質問を登録する場合" do
      it "新しい質問を追加できる" do
        sign_in user, scope: :user
        question1 = create(:question)
        question2 = create(:question)

        expect {
          post visit_question_selections_path(visit), params: {
            visit: { question_ids: [ question1.id.to_s, question2.id.to_s ] }
          }
        }.to change(QuestionSelection, :count).by(2)

        expect(response).to redirect_to(visit_question_selections_path(visit, page: "list"))
        expect(flash[:notice]).to eq("質問が追加されました")
      end

      it "重複する質問は追加されない" do
        sign_in user, scope: :user
        existing_question = create(:question)
        create(:question_selection, visit: visit, question: existing_question, user: user)
        new_question = create(:question)

        expect {
          post visit_question_selections_path(visit), params: {
            visit: { question_ids: [ existing_question.id.to_s, new_question.id.to_s ] }
          }
        }.to change(QuestionSelection, :count).by(1)
      end

      it "質問が選ばれていなくてもエラーにならない" do
        sign_in user, scope: :user
        expect {
          post visit_question_selections_path(visit), params: {
            visit: { question_ids: [] }
          }
        }.not_to change(QuestionSelection, :count)

        expect(response).to redirect_to(visit_question_selections_path(visit, page: "list"))
      end

      it "空欄や選択なしが混じっていても、正しい質問だけ登録される" do
        sign_in user, scope: :user
        question1 = create(:question)

        expect {
          post visit_question_selections_path(visit), params: {
            visit: { question_ids: [ question1.id.to_s, "", nil ] }
          }
        }.to change(QuestionSelection, :count).by(1)
      end
    end

    context "他の人の受診データにアクセスする場合" do
      it "他の人のデータに質問を追加しようとするとエラーになる" do
        sign_in user, scope: :user
        other_user = create(:user)
        other_visit = create(:visit, user: other_user)
        post visit_question_selections_path(other_visit), params: { visit: { question_ids: [ question.id.to_s ] } }
        expect(response).to have_http_status(404)
      end
    end
  end

  describe "PATCH /visits/:visit_id/question_selections/:id" do
    let(:question_selection) { create(:question_selection, visit: visit, question: question, user: user, asked: false) }

    context "質問を『未質問／質問済み』状態に切り替える場合" do
      it "切り替わる" do
        sign_in user, scope: :user
        expect(question_selection.asked).to be false

        patch visit_question_selection_path(visit, question_selection), params: {
          toggle_asked: true
        }

        question_selection.reload
        expect(question_selection.asked).to be true
      end

      it "画面更新なしで結果を表示できる" do
        sign_in user, scope: :user
        patch visit_question_selection_path(visit, question_selection),
              params: { toggle_asked: true },
              headers: { "Accept" => "text/vnd.turbo-stream.html" }

        expect(response).to have_http_status(200)
        expect(response.content_type).to include("text/vnd.turbo-stream.html")
      end

      it "API（JSON形式）で結果が表示できる" do
        sign_in user, scope: :user
        patch visit_question_selection_path(visit, question_selection),
              params: { toggle_asked: true },
              headers: { "Accept" => "application/json" }

        expect(response).to have_http_status(200)
        json = JSON.parse(response.body)
        expect(json["asked"]).to be true
      end

      it "通常のHTMLリクエストなら画面を切り替えてメッセージが表示される" do
        sign_in user, scope: :user
        patch visit_question_selection_path(visit, question_selection), params: {
          toggle_asked: true
        }

        expect(response).to redirect_to(visit_question_selections_path(visit, page: "list"))
        expect(flash[:notice]).to eq("状態を更新しました")
      end
    end

    context "切り替えの指示がない場合" do
      it "何も更新されない" do
        sign_in user, scope: :user
        expect {
          patch visit_question_selection_path(visit, question_selection), params: {}
        }.not_to change { question_selection.reload.asked }
      end
    end
  end

  describe "DELETE /visits/:visit_id/question_selections/:id" do
    let!(:question_selection) { create(:question_selection, visit: visit, question: question, user: user) }

    context "質問選択を削除する場合" do
      it "質問選択を削除できる" do
        sign_in user, scope: :user
        expect {
          delete visit_question_selection_path(visit, question_selection)
        }.to change(QuestionSelection, :count).by(-1)
      end

      it "画面更新なしでも削除できる" do
        sign_in user, scope: :user
        delete visit_question_selection_path(visit, question_selection),
               headers: { "Accept" => "text/vnd.turbo-stream.html" }

        expect(response).to have_http_status(200)
        expect(response.content_type).to include("text/vnd.turbo-stream.html")
      end

      it "遷移される" do
        sign_in user, scope: :user
        delete visit_question_selection_path(visit, question_selection)

        expect(response).to redirect_to(visit_question_selections_path(visit, page: "list"))
        expect(flash[:notice]).to eq("質問を削除しました")
      end
    end

    context "他の人の質問を削除しようとする場合" do
      it "データが見つからずエラーになる" do
        sign_in user, scope: :user
        other_user = create(:user)
        other_visit = create(:visit, user: other_user)
        other_selection = create(:question_selection, visit: other_visit, user: other_user)
        delete visit_question_selection_path(other_visit, other_selection)
        expect(response).to have_http_status(404)
      end
    end
  end

  describe "プライベートメソッドのテスト" do
    context "診療科を指定せず検索した場合" do
      it "診療科が設定されていない質問だけが表示される" do
        sign_in user, scope: :user
        question_with_dept = create(:question, department: department)
        question_without_dept = create(:question, department: nil)

        get visit_question_selections_path(visit, page: "select", department_id: "none")

        expect(response.body).not_to include(question_with_dept.content)
      end
    end

    context "カテゴリが指定されていない場合" do
      it "カテゴリが設定されていない質問が表示される" do
        sign_in user, scope: :user
        question_with_category = create(:question, question_category: question_category)
        question_without_category = create(:question, question_category: nil)

        get visit_question_selections_path(visit, page: "select", question_category_id: "none")

        expect(response.body).not_to include(question_with_category.content)
      end
    end

    context "複数の絞り込み条件を同時に指定した場合" do
      it "該当する質問のみ表示される" do
        sign_in user, scope: :user
        target_question = create(:question,
          content: "特定の症状について",
          department: department,
          question_category: question_category
        )
        other_question = create(:question, content: "別の症状について")

        get visit_question_selections_path(visit,
          page: "select",
          department_id: department.id,
          question_category_id: question_category.id,
          keyword: "特定"
        )

        expect(response).to have_http_status(200)
        expect(response.body).to include("受診時に聞きたい質問を確認しましょう")
      end
    end
  end
end
