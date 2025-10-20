require "rails_helper"

RSpec.describe "visits", type: :request do
  let(:user) { create(:user) }
  let(:department) { create(:department, name: "内科") }
  let(:visit) { create(:visit, user: user, department: department) }

  describe "受診予定の表示(GET /index)" do
    context "ログインしている場合" do
      it "受診先予定の一覧が表示される" do
        sign_in user, scope: :user
        get visits_path
        expect(response).to have_http_status(200)
        expect(response.body).to include("受診予定")
      end
    end

    context "ログインしていない場合" do
      it "ログインページに遷移される" do
        get visits_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "新規登録ページの表示(GET /new)" do
    context "ログインしている場合" do
      it "新規登録ページが表示される" do
        sign_in user, scope: :user
        get new_visit_path
        expect(response).to have_http_status(200)
        expect(response.body).to include("受診の予定を追加")
      end
    end

    context "ログインしていない場合" do
      it "ログインページに遷移される" do
        get new_visit_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "受診予定の登録処理(POST /create)" do
    context "ログインしていて、入力内容が正しい場合" do
      it "受診予定が保存される" do
        sign_in user, scope: :user
        visit_params = attributes_for(:visit, department_id: department.id)

        expect { post visits_path, params: { visit: visit_params } }.to change(Visit, :count).by(1)
        created_visit = Visit.last
        expect(response).to redirect_to(visits_path(date: created_visit.visit_date))
        expect(flash[:notice]).to eq("予定を保存しました")
      end
    end

    context "ログインしていて、入力内容に誤りがある場合" do
      it "保存に失敗し、同じページが再表示される" do
        sign_in user, scope: :user
        invalid_params = attributes_for(:visit, hospital_name: "", purpose: "", visit_date: nil, appointed_at: nil)
        expect { post visits_path, params: { visit: invalid_params } }.not_to change(Visit, :count)
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "ログインしていない場合" do
      it "ログインページに遷移される" do
        visit_params = attributes_for(:visit, department_id: department.id)
        post visits_path, params: { visit: visit_params }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "編集ページの表示(GET /edit)" do
    context "ログインしている場合" do
      it "編集ページが正しく表示される" do
        sign_in user, scope: :user
        get edit_visit_path(visit)
        expect(response).to have_http_status(200)
        expect(response.body).to include("編集")
      end
    end

    context "ログインしていない場合" do
      it "ログインページに遷移される" do
        get edit_visit_path(visit)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "受診予定の更新処理(PATCH /update)" do
    context "ログインしていて、入力内容が正しい場合" do
      it "受診予定が更新される" do
        sign_in user, scope: :user
        updated_params = attributes_for(:visit, hospital_name: "大阪病院")

        patch visit_path(visit), params: { visit: updated_params }
        expect(response).to redirect_to(visits_path)
        expect(flash[:notice]).to eq("予定を更新しました")
        expect(visit.reload.hospital_name).to eq("大阪病院")
      end
    end

    context "ログインしていて、入力内容に誤りがある場合" do
      it "更新に失敗し、同じページが再表示される" do
        sign_in user, scope: :user
        patch visit_path(visit), params: { visit: { hospital_name: "" } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "ログインしていない場合" do
      it "ログインページに遷移される" do
        updated_params = attributes_for(:visit, hospital_name: "大阪病院")
        patch visit_path(visit), params: { visit: updated_params }
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "受診予定の削除処理(DELETE /destroy)" do
    context "ログインしている場合" do
      it "受診予定が削除される" do
        sign_in user, scope: :user
        target_visit = create(:visit, user: user, department: department)
        expect { delete visit_path(target_visit) }.to change(Visit, :count).by(-1)
        expect(response).to redirect_to(visits_path(date: target_visit.visit_date))
        expect(flash[:notice]).to eq("予定を削除しました")
      end
    end

    context "ログインしていない場合" do
      it "ログインページに遷移される" do
        delete visit_path(visit)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
