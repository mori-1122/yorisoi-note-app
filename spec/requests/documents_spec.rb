require 'rails_helper'

RSpec.describe "Documents", type: :request do
  let(:user) { create(:user) }
  let(:visit) { create(:visit, user: user) }
  let(:image_file) { fixture_file_upload(Rails.root.join("spec/fixtures/files/document_sample.png"), "image/png") }

  context "ログインしているとき（GET /index）" do
    it "書類一覧ページが正しく表示される" do
      sign_in user, scope: :user
      get visit_documents_path(visit)

      expect(response).to have_http_status(200)
      expect(response.body).to include("書類一覧").or include("アップロード")
    end
  end

  context "ログインしていないとき（GET /index）" do
    it "ログインページに遷移される" do
      get visit_documents_path(visit)

      expect(response).to redirect_to(new_user_session_path)
    end
  end

  context "ログインしていて画像をアップロードする場合（POST /create）" do
    it "画像が保存される" do
      sign_in user, scope: :user
      document_params = { image: image_file, doc_type: "test_result" }

      post visit_documents_path(visit), params: { document: document_params }

      expect(response).to have_http_status(302)
      expect(Document.last.doc_type).to eq(document_params[:doc_type])
      expect(Document.last.user).to eq(user)
      expect(Document.last.visit).to eq(visit)
      expect(flash[:notice]).to eq("画像をアップロードしました。")
    end
  end

  context "ログインしていて画像がない場合（POST /create）" do
    it "保存に失敗する" do
      sign_in user, scope: :user
      document_params = { image: nil, doc_type: "" }

      expect {
        post visit_documents_path(visit), params: { document: document_params }
      }.not_to change(Document, :count)

      expect(response).to have_http_status(:unprocessable_entity)
      expect(flash[:error]).to eq("アップロードに失敗しました。")
    end
  end

  context "ログインしていないとき（POST /create）" do
    it "ログインページに遷移される" do
      document_params = { image: image_file, doc_type: "test_result" }

      post visit_documents_path(visit), params: { document: document_params }

      expect(response).to redirect_to(new_user_session_path)
    end
  end

  context "ログインしていて編集ページを開く場合（GET /edit）" do
    it "画像の編集ページが表示される" do
      sign_in user, scope: :user
      document = create(:document, user: user, visit: visit)
      get edit_visit_document_path(visit, document)

      expect(response).to have_http_status(200)
      expect(response.body).to include("編集")
    end
  end

  context "ログインをしていない場合" do
    it "ログインページに遷移される" do
      document = create(:document, user: user, visit: visit)
      get edit_visit_document_path(visit, document)

      expect(response).to redirect_to(new_user_session_path)
    end
  end

  context "ログインしていて画像を更新する場合(PATCH/ update)" do
    it "画像が更新される" do
      sign_in user, scope: :user
      document = create(:document, user: user, visit: visit)
      new_image = fixture_file_upload(Rails.root.join("spec/fixtures/files/document_sample.png"), "image/png")
      patch visit_document_path(visit, document), params: { document: { image: new_image } }
      expect(response).to redirect_to(visit_documents_path(visit))
      expect(flash[:notice]).to eq("画像を更新しました。")
    end
  end

  context "ログインしていて更新が失敗する場合(PATCH/ update)" do
    it "エラーメッセージが表示される" do
      sign_in user, scope: :user
      document = create(:document, user: user, visit: visit)
      patch visit_document_path(visit, document), params: { document: { doc_type: "" } }
      expect(response).to have_http_status(:unprocessable_entity)
      expect(flash[:error]).to eq("更新に失敗しました。")
    end
  end

  context "ログインしていて削除する場合(DELETE/ destroy)" do
    it "画像が削除される" do
      sign_in user, scope: :user
      document = create(:document, user: user, visit: visit)
      expect { delete visit_document_path(visit, document) }.to change(Document, :count).by(-1)
      expect(Document.exists?(document.id)).to be false
    end
  end

  context "ログインしていない場合(DELETE/ destroy)" do
    it "ログインページに遷移される" do
      document = create(:document, user: user, visit: visit)
      delete visit_document_path(visit, document)
      expect(response).to have_http_status(:found)
      expect(response).to redirect_to(new_user_session_path)
    end

    it "削除完了メッセージが表示される" do
      sign_in user, scope: :user
      document = create(:document, user: user, visit: visit)
      delete visit_document_path(visit, document)
      expect(flash[:notice]).to eq("画像を削除しました。")
    end
  end
end
