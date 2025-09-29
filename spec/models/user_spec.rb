require 'rails_helper'

RSpec.describe User, type: :model do
  describe "バリデーション" do
    context "有効な場合" do
      let(:user) { build(:user) }

      it "名前、メールアドレス、パスワードが入力されていれば有効である" do
        expect(user).to be_valid
      end
    end

    context "登録できない場合" do
      it "名前が空では無効である" do
        user = build(:user, name: "")
        user.valid?
        expect(user.errors[:name]).to include("を入力してください")
      end

      it "メールアドレスが空の場合は無効である" do
        user = build(:user, email: "")
        user.valid?
        expect(user.errors[:email]).to include("を入力してください")
      end

      it "パスワードが空の場合は無効である" do
        user = build(:user, password: "")
        user.valid?
        expect(user.errors[:password]).to include("を入力してください")
      end

      it "メールアドレスが重複している場合は無効である" do
        create(:user, email: "test@example.com")
        user = build(:user, email: "test@example.com")
        user.valid?
        expect(user.errors[:email]).to include("はすでに存在します")
      end
    end
  end
end
