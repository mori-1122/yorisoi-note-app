require 'rails_helper'

RSpec.describe Visit, type: :model do
  let(:user) { create(:user) }
  let(:department) { create(:department, name: "内科") }

  context "必須項目が揃っている場合" do
    let(:visit) { build(:visit, user: user, department: department) }

    it "有効である" do
      expect(visit.valid?).to be true
    end
  end

  context "診療科がない場合" do
    let(:visit) { build(:visit, user: user, department: nil) }

    it "無効である" do
      expect(visit.valid?).to be false
      expect(visit.errors[:department]).to include("を入力してください")
    end
  end

  context "受診予定日が空の場合" do
    let(:visit) { build(:visit, user: user, department: department, visit_date: nil) }

    it "無効である" do
      expect(visit.valid?).to be false
      expect(visit.errors[:visit_date]).to include("を入力してください")
    end
  end

  context "受診予定日が過去の日付の場合" do
    let(:visit) { build(:visit, user: user, department: department, visit_date: Date.yesterday) }

    it "無効である" do
      expect(visit.valid?).to be false
      expect(visit.errors[:visit_date]).to include("は、今日以降の日付を指定してください。")
    end
  end

  context "受診予定時間が過去の場合" do
    let(:visit) { build(:visit, user: user, department: department, visit_date: Date.today, appointed_at: 1.day.ago) }

    it "無効である" do
      expect(visit.valid?).to be false
      expect(visit.errors[:appointed_at]).to include("は、現在以降の日時を指定してください。")
    end
  end

  context "同じユーザーで同じ日・同じ時間に重複登録した場合" do
    let!(:existing_visit) { create(:visit, user: user, department: department, visit_date: Date.tomorrow, appointed_at: Time.zone.parse("10:00")) }
    let(:new_visit) { build(:visit, user: user, department: department, visit_date: Date.tomorrow, appointed_at: Time.zone.parse("10:00")) }

    it "無効である" do
      expect(new_visit.valid?).to be false
      expect(new_visit.errors[:appointed_at]).to include("は、すでに他の予定と重複して登録されています。")
    end
  end

  context "受診日と受診予約時間が結合される場合" do
    let(:visit) { build(:visit, user: user, department: department, visit_date: Date.today, appointed_at: 1.hour.from_now) }

    it "有効である" do
      expect(visit.valid?).to be true
      expect(visit.appointed_at.strftime("%H:%M")).to eq(1.hour.from_now.strftime("%H:%M"))
    end
  end

  context "受診予定日が今日の場合" do
    let(:visit) { build(:visit, user: user, department: department, visit_date: Date.today, appointed_at: 1.hour.from_now) }

    it "有効である" do
      expect(visit.valid?).to be true
    end
  end

  context "受診予定時間を現在時刻で登録した場合" do
    let(:visit) { build(:visit, user: user, department: department, visit_date: Date.today, appointed_at: Time.zone.now) }

    it "無効である" do
      expect(visit.valid?).to be false
      expect(visit.errors[:appointed_at]).to include("は、現在以降の日時を指定してください。")
    end
  end

  context "通知メールの作成処理" do
    let(:visit) { create(:visit, user: user, department: department, visit_date: Date.tomorrow, appointed_at: "10:00") }

    it "受診予定を登録すると即時通知と前日通知が作成される" do
      visit.create_notifications

      expect(visit.notifications.count).to eq(2)

      immediate = visit.notifications.find_by(title: "【受診予定を新規登録しました】東京病院")
      reminder  = visit.notifications.find_by(title: "【受診に関するリマインド】東京病院")

      # 即時通知
      expect(immediate).not_to be_nil
      expect(immediate.due_date).to eq(Date.current)
      expect(immediate.is_sent).to be false

      # 前日通知
      expect(reminder).not_to be_nil
      expect(reminder.due_date).to eq(Date.tomorrow - 1.day)
      expect(reminder.is_sent).to be false
    end
  end
end
