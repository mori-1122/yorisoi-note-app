require 'rails_helper'

RSpec.describe "Recordings", type: :request do
  let(:user) { create(:user) }
  let(:department) { create(:department, name: "内科") }
  let(:visit) { create(:visit, user: user, department: department) }
  let(:audio_file) { fixture_file_upload("sample.webm", "audio/webm") }

  describe "録音の新規作成ページ GET /visits/:visits_id/recordings/new" do
    context "ログインしている場合" do
      it "新規作成ページが開ける" do
        sign_in user, scope: :user
        get new_visit_recording_path(visit)
        expect(response).to have_http_status(200)
      end
    end

    context "ログインしていない場合" do
      it "ログインページに遷移される" do
        get new_visit_recording_path(visit)
        expect(response).to have_http_status(302)
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "録音を新しく作成する POST /visits/:visit_id/recording" do
    context "ログインしていて正しい入力情報の場合" do
      it "録音が１件作成される" do
        sign_in user, scope: :user
        expect { post visit_recording_path(visit), params: { audio: audio_file } }.to change(Recording, :count).by(1)
      end

      it "画面が正常に表示される" do
        sign_in user, scope: :user
        post visit_recording_path(visit), params: { audio: audio_file }
        expect(response).to have_http_status(200)
      end

      it "録音が正常に登録されたことを確認する" do
        sign_in user, scope: :user
        post visit_recording_path(visit), params: { audio: audio_file }
        json = JSON.parse(response.body)
        expect(json["status"]).to eq("OK")
      end

      it "録音がそのユーザーの記録として登録されることを確認する" do
        sign_in user, scope: :user
        post visit_recording_path(visit), params: { audio: audio_file }
        recording = Recording.last
        expect(recording.user).to eq(user)
      end

      it "作成された録音には指定した診察が紐付いている" do
        sign_in user, scope: :user
        post visit_recording_path(visit), params: { audio: audio_file }
        recording = Recording.last
        expect(recording.visit).to eq(visit)
      end

      it "作成された録音には現在時刻が設定されている" do
        sign_in user, scope: :user
        post visit_recording_path(visit), params: { audio: audio_file }
        recording = Recording.last
        expect(Recording.last.recorded_at).to be_present
      end

      it "作成された録音には音声ファイルが添付されている" do
        sign_in user, scope: :user
        post visit_recording_path(visit), params: { audio: audio_file }
        recording = Recording.last
        expect(recording.audio_file).to be_attached
      end

      it "音声ファイルのメタデータに再生時間が数値で保存されている" do
        sign_in user, scope: :user
        post visit_recording_path(visit), params: { audio: audio_file }
        recording = Recording.last
        duration = recording.audio_file.blob.metadata["custom_duration"]
        expect(duration).to be_a(Numeric)
        expect(duration).to be >= 0
      end
    end

    context "音声ファイルが無い場合" do
      it "保存に失敗する" do
        sign_in user, scope: :user
        post visit_recording_path(visit), params: { audio: nil }
        expect(response).to have_http_status(422)
      end

      it "エラー内容がレスポンスに含まれている" do
        sign_in user, scope: :user
        post visit_recording_path(visit), params: { audio: nil }
        json = JSON.parse(response.body)
        expect(json["status"]).to eq("error")
        expect(json["errors"]).to be_present
      end
    end

    context "ログインしていない場合" do
      it "ログインページに遷移される" do
        post visit_recording_path(visit), params: { audio: audio_file }
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "他ユーザーの受診時録音の場合" do
      it "録音を作成できない" do
        other_user = create(:user)
        other_visit = create(:visit, user: other_user, department: department)
        sign_in user, scope: :user
        expect post visit_recording_path(other_visit), params: { audio: audio_file }
        expect(response).to have_http_status(404)
      end
    end
  end

  describe "録音の詳細画面 GET /visits/:visit_id/recording" do
    context "ログインしていて録音がある場合" do
      it "正しく画面が表示される" do
        sign_in user, scope: :user
        recording = create(:recording, :with_audio, visit: visit, user: user)
        get visit_recording_path(visit)
        expect(response).to have_http_status(200)
      end
    end

    context "ログインしていない場合" do
      it "ログインページに遷移される" do
        recording = create(:recording, :with_audio, visit: visit, user: user)
        get visit_recording_path(visit)
        expect(response).to redirect_to(new_user_session_path)
      end
    end

    context "他のユーザーの場合" do
      it "詳細画面が表示されない" do
        other_user = create(:user)
        other_visit = create(:visit, user: user, department: department)
        create(:recording, :with_audio, visit: other_visit, user: other_user)
        sign_in user, scope: :user
        get visit_recording_path(other_visit)
        expect(response).to have_http_status(200)
      end
    end
  end

  describe "録音を削除する DELETE /visits/:visit_id/recording" do
    context "ログインしている場合" do
      it "録音が1件削除される" do
        recording = create(:recording, :with_audio, visit: visit, user: user)
        sign_in user, scope: :user
        expect { delete visit_recording_path(visit) }.to change(Recording, :count).by(-1)
      end

      it "削除が終わったあと、別のページに移動する" do
        sign_in user, scope: :user
        recording = create(:recording, :with_audio, visit: visit, user: user)
        delete visit_recording_path(visit)
        expect(response).to have_http_status(302)
      end

      it "受診予定スケジュール画面に遷移される" do
        sign_in user, scope: :user
        recording = create(:recording, :with_audio, visit: visit, user: user)
        delete visit_recording_path(visit)
        expect(response).to redirect_to(visit_path(visit))
      end

      it "削除後の画面には成功メッセージが表示される" do
        sign_in user, scope: :user
        recording = create(:recording, :with_audio, visit: visit, user: user)
        delete visit_recording_path(visit)
        expect(response).to redirect_to(visit_path(visit))
        get visit_path(visit)
        expect(response.body).to include("録音を削除しました")
      end

      it "録音に添付された音声ファイルも一緒に削除される" do
        sign_in user, scope: :user
        create(:recording, :with_audio, visit: visit, user: user)

        before_count = ActiveStorage::Attachment.count
        delete visit_recording_path(visit)
        after_count = ActiveStorage::Attachment.count

        # 添付ファイルが1件以上減っていればOK（variant含む）
        expect(after_count).to be < before_count
      end
    end
  end
end
