require 'rails_helper'

RSpec.describe Department, type: :model do
  describe "バリデーション" do
    context "全ての情報が正しい場合" do
      let(:department) { build(:department, name: "内科") }

      it "登録できる" do
        expect(department.valid?).to be true
      end
    end

    context "診療科名がみ入力の場合" do
      let(:department) { build(:department, name: nil) }

      it "登録できない" do
        expect(department.valid?).to be false
        expect(department.errors[:name]).to include("を入力してください")
      end
    end
  end
end
