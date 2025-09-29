require 'rails_helper'

RSpec.describe Visit, type: :model do
  let!(:user) { create(:user) }
  let!(:department) { create(:department, name: "内科") }

  context "有効な場合" do
    it "必須項目が揃っていれば有効である" do
      visit = build(:visit, user: user, department: department)
      expect(visit).to be_valid
    end
  end

  context "無効な場合" do
    it "診療科がなければ無効である" do
      visit = build(:visit, user: user, department: nil)
      visit.valid?
      expect(visit.errors[:department]).to include("を入力してください")
    end

    it "受診予定日が空では保存できない" do
      visit = build(:visit, user: user, department: department, visit_date: nil)
      visit.valid?
      expect(visit.errors[:visit_date]).to include("を入力してください")
    end

    it "受診予定日が過去の日付では保存できない" do
      visit = build(:visit, user: user, department: department, visit_date: Date.yesterday)
      visit.valid?
      expect(visit.errors[:visit_date]).to include("は、今日以降の日付を指定してください。")
    end

    it "受診予定時間が過去では保存できない" do
      visit = build(:visit, user: user, department: department, visit_date: Date.yesterday, appointed_at: 1.day.ago)
      visit.valid?
      expect(visit.errors[:appointed_at]).to include("は、現在以降の日時を指定してください。")
    end

    it "同じユーザーで同じ日、同じ時間は重複登録できない" do
      create(:visit, user: user, department: department, visit_date: Date.tomorrow, appointed_at: "10:00")
      new_visit = build(:visit, user: user, department: department, visit_date: Date.tomorrow, appointed_at: "10:00")
      new_visit.valid?
      expect(new_visit.errors[:appointed_at]).to include("は、すでに他の予定と重複して登録されています。")
    end
  end

  describe "日時結合の処理" do
    it "受診日と受診予約時間が結合される" do
      visit = build(:visit, user: user, department: department, visit_date: Date.today, appointed_at: "10:00")
      visit.valid?
      expect(visit.appointed_at.strftime("%H:%M")).to eq("10:00")
    end
  end

  describe "通知メールの作成処理" do
    it "受診予定を登録すると即時通知と前日通知が作成される" do
      visit = create(:visit, user: user, department: department, visit_date: Date.tomorrow, appointed_at: "10:00")
      visit.create_notifications

      expect(visit.notifications.count).to eq(2)

      immediate = visit.notifications.find_by(title: "【受診予定を新規登録しました】東京病院")
      reminder = visit.notifications.find_by(title: "【受診に関するリマインド】東京病院")

      # 即時通知
      expect(immediate).not_to be_nil
      expect(immediate.due_date).to eq(Date.current)
      expect(immediate.is_sent).to be(false) # レコードを作ったけどまだ送っていないことを期待する


      # 前日通知
      expect(reminder).not_to be_nil
      expect(reminder.due_date).to eq(Date.tomorrow - 1.day)
      expect(reminder.is_sent).to be(false)
    end
  end
end
