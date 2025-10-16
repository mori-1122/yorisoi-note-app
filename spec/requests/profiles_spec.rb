require 'rails_helper'

RSpec.describe "Profiles", type: :request do
  let(:user) { create(:user) }

  describe "プロフィール編集画面の表示 GET /profiles" do
    context "ログインしている場合" do
      it "正常に表示される" do
        sign_in user, scope: :user
        get edit_profile_path
        expect(response).to have_http_status(200)
      end

      it "編集画面が表示される" do
        sign_in user, scope: :user
        get edit_profile_path
        expect(response.body).to include("プロフィール")
        expect(response.body).to include("生年月日")
        expect(response.body).to include("性別")
      end
    end

    context "プロフィールがまだ登録されていない場合" do
      it "問題なく画面が表示される" do
        sign_in user, scope: :user
        get edit_profile_path
        expect(response).to have_http_status(200)
      end

      it "新しいプロフィールを作成できる（まだ保存はされない）" do
        sign_in user, scope: :user
        get edit_profile_path
        expect(Profile.exists?(user_id: user.id)).to be false
      end
    end

    context "ログインしていない場合" do
      it "ログインページに遷移される" do
        get edit_profile_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end

  describe "プロフィール更新処理 PATCH /profile" do
    let(:valid_params) do
      {
        profile: {
          birthday: "1990-01-01",
          gender: "male",
          height: 170,
          weight: 60,
          blood_type: "A",
          allergy_details: "花粉症",
          medical_history: "なし",
          current_medication: "ビタミン剤"
        }
      }
    end

    let(:invalid_params) do
      { profile: { height: -1, weight: -1 } }
    end

    context "ログインしている場合" do
      before do
        sign_in user, scope: :user
      end

      context "既存のプロフィールがある場合" do
        let!(:profile) { create(:profile, user: user, height: 160, weight: 55) }

        it "正しい情報ならプロフィールを更新できる" do
          patch profile_path, params: valid_params
          profile.reload

          expect(profile.height).to eq(170)
          expect(profile.weight).to eq(60)
          expect(profile.blood_type).to eq("A")
          expect(profile.allergy_details).to eq("花粉症")
        end

        it "更新成功時はリダイレクトされ、フラッシュメッセージが表示される" do
          patch profile_path, params: valid_params

          expect(response).to redirect_to(edit_profile_path)
          expect(flash[:notice]).to eq("プロフィールを更新しました。")
        end

        it "入力内容に誤りがあると更新できない" do
          patch profile_path, params: invalid_params
          profile.reload

          expect(profile.height).to eq(160)
          expect(profile.weight).to eq(55)
        end

        it "無効な入力のときはエラーメッセージが表示される" do
          patch profile_path, params: invalid_params

          expect(response).to have_http_status(:unprocessable_entity)
          expect(response.body).to include("更新できませんでした。")
        end

        it "height と weight は数値以外を受け付けない" do
          non_numeric_params = {
            profile: {
              height: "abc",
              weight: "xyz"
            }
          }

          patch profile_path, params: non_numeric_params
          profile.reload

          expect(profile.height).to eq(160)
          expect(profile.weight).to eq(55)
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end

      context "プロフィールがまだ存在しない場合" do
        it "新しいプロフィールを作成できる" do
          expect {
            patch profile_path, params: valid_params
          }.to change(Profile, :count).by(1)

          profile = user.reload.profile
          expect(profile.height).to eq(170)
          expect(profile.weight).to eq(60)
        end
      end
    end

    context "ログインしていない場合" do
      it "ログインページに遷移される" do
        patch profile_path, params: valid_params
        expect(response).to redirect_to(new_user_session_path)
      end

      it "プロフィールが更新されない" do
        profile = create(:profile, user: user, height: 160)
        patch profile_path, params: { profile: { height: 180 } }
        profile.reload
        expect(profile.height).to eq(160)
      end
    end

    context "他のユーザーとしてログインしている場合" do
      let(:other_user) { create(:user) }
      let!(:profile) { create(:profile, user: user, height: 160) }

      before do
        sign_in other_user, scope: :user
      end

      it "他人のプロフィールは更新できない" do
        patch profile_path, params: { profile: { height: 180 } }
        profile.reload
        expect(profile.height).to eq(160)
      end

      it "自分のプロフィールが新規作成される" do
        expect {
          patch profile_path, params: valid_params
        }.to change(Profile, :count).by(1)

        new_profile = other_user.reload.profile
        expect(new_profile).to be_present
        expect(new_profile.height).to eq(170)
      end
    end
  end
end
