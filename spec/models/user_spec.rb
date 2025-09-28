require 'rails_helper'

RSpec.describe User, type: :model do
  context "名前、メールアドレス、パスワードが入力されている場合" do
    let!(:user) { create(:user) }

    it "有効である" do
      expect(user).to be_valid
    end
  end

  context "登録できない場合" do
    it "名前が空では無効である" do
      user = User.new(name: "", email: "test@example.com", password: "password")
      user.valid?
      expect(user.errors[:name]).to include("を入力してください")
    end

    it "メールアドレスが空の場合は無効である" do
      user = User.new(name: "テスト", email: "", password: "password")
      user.valid?
      expect(user.errors[:email]).to include("を入力してください")
    end

    it "パスワードが空の場合は無効である" do
      user = User.new(name: "テスト", email: "test@example.com", password: "")
      user.valid?
      expect(user.errors[:password]).to include("を入力してください")
    end

    it "メールアドレスが重複している場合は無効である" do
      User.create!(name: "テスト", email: "test@example.com", password: "password")
      user = User.new(name: "テスト2", email: "test@example.com", password: "password")
      user.valid?
      expect(user.errors[:email]).to include("はすでに存在します")
    end
  end
end
