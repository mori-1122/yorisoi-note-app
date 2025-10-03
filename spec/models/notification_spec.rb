require 'rails_helper'

RSpec.describe Notification, type: :model do
  describe "バリデーション" do
    context "有効な場合" do
      let(:notification) { build(:notification) }

      it "バリデーションを通る" do
        expect(notification.valid?).to be true
      end
    end

    context "タイトルが空の場合" do
      let(:notification) { build(:notification, title: nil) }

      it "無効である" do
        expect(notification.valid?).to be false
        expect(notification.errors[:title]).to include("を入力してください")
      end
    end

    context "受診予定日が空の場合" do
      let(:notification) { build(:notification, due_date: nil) }

      it "無効である" do
        expect(notification.valid?).to be false
        expect(notification.errors[:due_date]).to include("を入力してください")
      end
    end

    context "ユーザーが紐づいていない場合" do
      let(:notification) { build(:notification, user: nil) }

      it "無効である" do
        expect(notification.valid?).to be false
        expect(notification.errors[:user]).to include("を入力してください")
      end
    end

    context "受診の予定が紐ついていない場合" do
      let(:notification) { build(:notification, visit: nil) }

      it "無効である" do
        expect(notification.valid?).to be false
        expect(notification.errors[:visit]).to include("を入力してください")
      end
    end

    context "is_sent のデフォルト値がfalseである場合" do
      let(:notification) { create(:notification) }

      it "falseである" do
        expect(notification.is_sent).to be false
      end
    end
  end
end
