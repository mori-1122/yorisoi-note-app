require 'rails_helper'

RSpec.describe Profile, type: :model do
  describe "バリデーション" do
    let(:user) { create(:user) }

    context "全ての必須項目が正しく入力されている場合" do
      let(:profile) { build(:profile, user: user, birthday: "1985-01-01", gender: 0, height: 180, weight: 80) }

      it "登録できる" do
        expect(profile.valid?).to be true
      end
    end

    context "生年月日がみ入力の場合" do
      let(:profile) { build(:profile, user: user, birthday: nil, gender: 0) }

      it "登録できない" do
        expect(profile.valid?).to be false
        expect(profile.errors[:birthday]).to include("を入力してください")
      end
    end

    context "性別が未入力の場合" do
      let(:profile) { build(:profile, user: user, birthday: "1985-01-01", gender: nil) }

      it "登録できない" do
        expect(profile.valid?).to be false
        expect(profile.errors[:gender]).to include("を入力してください")
      end
    end

    context "身長、体重が0以下の値の場合" do
      it "登録できない" do
        invalid_profile = build(:profile, user: user, height: 0, weight: -5)
        expect(invalid_profile.valid?).to be false
        expect(invalid_profile.errors[:height]).to include("は0より大きい値にしてください")
        expect(invalid_profile.errors[:weight]).to include("は0より大きい値にしてください")
      end
    end

    context "血液型が未指定ぼ場合" do
      let(:profile) { build(:profile, user: user, birthday: "1985-01-01", gender: 0, blood_type: nil) }

      it "デフォルトで「不明」になる" do
        profile.blood_type ||= "不明"
        expect(profile.blood_type).to eq("不明")
      end
    end
  end
end
