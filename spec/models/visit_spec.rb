require 'rails_helper'

RSpec.describe Visit, type: :model do
  let(:user) { create(:user) }
  let(:department) { create(:department, name: "内科") }

  context "必須項目が揃っている場合" do
    let(:visit) { build(:visit, user: user, department: department) }

    it "受診予定を登録できる" do
      expect(visit.valid?).to be true
    end
  end

  context "診療科がない場合" do
    let(:visit) { build(:visit, user: user, department: nil) }

    it "診療科がないと登録できない" do
      expect(visit.valid?).to be false
      expect(visit.errors[:department]).to include("を入力してください")
    end
  end

  context "受診予定日が空の場合" do
    let(:visit) { build(:visit, user: user, department: department, visit_date: nil) }

    it "受診予定日がないと登録できない" do
      expect(visit.valid?).to be false
      expect(visit.errors[:visit_date]).to include("を入力してください")
    end
  end

  context "受診予定日が過去の日付の場合" do
    let(:visit) { build(:visit, user: user, department: department, visit_date: Date.yesterday) }

    it "受診予定日は今日以降でなければ登録できない" do
      expect(visit.valid?).to be false
      expect(visit.errors[:visit_date]).to include("は、今日以降の日付を指定してください。")
    end
  end

  context "受診予定時間が過去の場合" do
    let(:visit) { build(:visit, user: user, department: department, visit_date: Date.today, appointed_at: 1.day.ago) }

    it "受診予定日は現時点以降でなければ登録できない" do
      expect(visit.valid?).to be false
      expect(visit.errors[:appointed_at]).to include("は、現在以降の日時を指定してください。")
    end
  end

  context "同じユーザーで同じ日・同じ時間に重複登録した場合" do
    let!(:existing_visit) { create(:visit, user: user, department: department, visit_date: Date.tomorrow, appointed_at: Time.zone.parse("10:00")) }
    let(:new_visit) { build(:visit, user: user, department: department, visit_date: Date.tomorrow, appointed_at: Time.zone.parse("10:00")) }

    it "同じ日時の受診予定は重複して登録できない" do
      expect(new_visit.valid?).to be false
      expect(new_visit.errors[:appointed_at]).to include("は、すでに他の予定と重複して登録されています。")
    end
  end

  context "受診日と受診予約時間が結合される場合" do
    let(:visit) { build(:visit, user: user, department: department, visit_date: Date.today, appointed_at: "10:00") }

    it "受診日と時刻を組み合わせて登録できる" do
      expect(visit.valid?).to be true
      expect(visit.appointed_at.strftime("%H:%M")).to eq("10:00")
    end
  end

  context "受診予定日が今日の場合" do
    let(:visit) { build(:visit, user: user, department: department, visit_date: Date.today, appointed_at: "10:00") }

    it "今日の受診予定を登録できる" do
      expect(visit.valid?).to be true
    end
  end

  context "受診予定時間を現在時刻で登録した場合" do
    let(:visit) { build(:visit, user: user, department: department, visit_date: Date.today, appointed_at: Time.zone.now) }

    it "受診予定時間が現在時刻と同じ場合は登録できない" do
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

  context "通知メールが作成された場合" do
    let(:visit) { create(:visit, user: user, department: department, visit_date: Date.tomorrow, appointed_at: "10:00") }

    it "visitとuserが紐ついて作成される" do
      visit.create_notifications
      notification = visit.notifications.first

      expect(notification.visit).to eq(visit)
      expect(notification.user).to eq(user)
    end
  end

  context "通知メールの初期状態" do
    let(:visit) { create(:visit, user: user, department: department, visit_date: Date.tomorrow, appointed_at: "10:00") }

    it "is_sentがfalseである" do
      visit.create_notifications
      notification = visit.notifications.first

      expect(notification.is_sent).to be false
    end
  end

  context "即時通知が作成される場合" do
    let(:visit) { create(:visit, user: user, department: department, visit_date: Date.tomorrow, appointed_at: "10:00", purpose: "検査") }

    it "タイトルと内容が正しい" do
      visit.create_notifications
      immediate = visit.notifications.find_by(title: "【受診予定を新規登録しました】東京病院")

      expect(immediate.title).to eq("【受診予定を新規登録しました】東京病院")
      expect(immediate.description).to include("日付： #{visit.visit_date.strftime("%-m月%-d日")}")
      expect(immediate.description).to include("時間：10:00")
      expect(immediate.description).to include("目的：検査")
    end
  end

  context "前日通知が作成される場合" do
    let(:visit) { create(:visit, user: user, department: department, visit_date: Date.tomorrow, appointed_at: "10:00", purpose: "検査") }

    it "タイトルと内容が正しい" do
      visit.create_notifications
      reminder = visit.notifications.find_by(title: "【受診に関するリマインド】東京病院")

      expect(reminder.title).to eq("【受診に関するリマインド】東京病院")
      expect(reminder.description).to include("明日は受診日です。")
      expect(reminder.description).to include("日付： #{visit.visit_date.strftime("%-m月%-d日")}")
      expect(reminder.description).to include("時間：10:00")
      expect(reminder.description).to include("目的：検査")
    end
  end
end
