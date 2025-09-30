require 'rails_helper'

RSpec.describe User, type: :model do
  describe "バリデーション" do
    context "有効な場合" do
      let(:user) { build(:user) }

      it "バリデーションを通る" do
        expect(user.valid?).to be true
      end
    end

    context "名前が空の場合" do
      let(:user) { build(:user, name: "") }

      it "無効である" do
        expect(user.valid?).to be false
        expect(user.errors[:name]).to include("を入力してください")
      end
    end

    context "メールアドレスが空の場合" do
      let(:user) { build(:user, email: "") }

      it "無効である" do
        expect(user.valid?).to be false
        expect(user.errors[:email]).to include("を入力してください")
      end
    end

    context "パスワードが空の場合" do
      let(:user) { build(:user, password: "") }

      it "無効である" do
        expect(user.valid?).to be false
        expect(user.errors[:password]).to include("を入力してください")
      end
    end

    context "メールアドレスの形式が不正な場合" do
      let(:user) { build(:user, email: "090-1111-2222") }

      it "無効である" do
        expect(user.valid?).to be false
        expect(user.errors[:email]).to include("は不正な値です")
      end
    end

    context "メールアドレスが重複している場合" do
      let!(:user1) { create(:user, email:"test@example.com") }
      let(:user2) { build(:user, email:"test@example.com") }

      it "無効である" do
        expect(user2.valid?).to be false
        expect(user2.errors[:email]).to include("はすでに存在します")
      end
    end
  end
end
