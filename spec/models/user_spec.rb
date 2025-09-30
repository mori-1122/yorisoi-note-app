require 'rails_helper'

RSpec.describe User, type: :model do
  # テスト対象・観点. テストしたいメソッドになることも多い
  describe "バリデーション" do
    # 正常系
    # context は条件を書く

    context "有効な場合" do
      let(:user) { build(:user) }

      # it は期待値
      it "バリデーションを通る" do
        expect(user.valid?).to be true
      end
    end

    # 以降、異常系
    # context には条件を書く
    context "名前が空の場合" do
      let(:user) { build(:user, name: '') }

      it "無効である" do
        # create: User.create!
        # build: User.new
        # user = build(:user, name: "") # build は good! create は DB に保存してしまうため

        # valid? はバリデーションにすべて通るかどうか？を検証している
        expect(user.valid?).to be false
        expect(user.errors[:name]).to include("を入力してください")
      end
    end

    # context は極力ネストさせないのがおすすめ。やって2段階までかな...
    context "メールアドレスが空の場合" do
      # 上で let で user を定義しているので、以降も合わせておくといいかも
      it "無効である" do
        user = build(:user, email: "")

        expect(user.valid?).to be false
        expect(user.errors[:email]).to include("を入力してください")
      end
    end

    context 'パスワードが空の場合' do
      it "無効である" do
        user = build(:user, password: "")

        expect(user.valid?).to be false
        expect(user.errors[:password]).to include("を入力してください")
        # 別解: エラーの検証方法の別パターン
        # expect(user.errors).to be_of_kind(:password, :blank)
      end
    end

    context "メールアドレスが重複している場合" do
      it "無効である" do
        create(:user, email: "test@example.com")
        user = build(:user, email: "test@example.com")

        expect(user.valid?).to be false
        expect(user.errors[:email]).to include("はすでに存在します")
      end
    end

    # 以下の部分のテストを書く
    # validates :email, ... format: { with: URI::MailTo::EMAIL_REGEXP }
    context "メールアドレスの形式が不正な場合" do
      it "無効である" do
        user = build(:user, email: "090-1111-2222")

        expect(user.valid?).to be false
        expect(user.errors).to be_of_kind(:email, :invalid_format)
      end
    end
  end
end
