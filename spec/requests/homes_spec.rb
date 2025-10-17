require 'rails_helper'

RSpec.describe "Homes", type: :request do
  describe "GET /homes" do
    context "ログインしていない場合" do
      it "トップ画面が表示される" do
        get root_path
        expect(response).to have_http_status(200)
      end
    end

    context "ログインしている場合" do
      let(:user) { create(:user) }

      it "カレンダー画面に遷移される" do
        sign_in user, scope: :user
        get root_path
        expect(response).to redirect_to(visits_path)
      end
    end
  end
end
