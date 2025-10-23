require "rails_helper"

RSpec.describe NotificationMailer, type: :mailer do
  describe "即時通知メール" do
    context "受診予定、通知しなければならないデータがある場合" do
      let(:user) do
        create(:user,
          name: "田中太郎",
          email: "test@example.com"
        )
      end

      let(:department) { create(:department, name: "内科") }

      let(:visit) do
        create(:visit,
          user: user,
          department: department,
          hospital_name: "東京病院",
          purpose: "検査",
          visit_date: Date.today,
          appointed_at: Time.zone.now + 2.hours
        )
      end

      # 即時通知レコードを作成
      let(:notification) do
        visit.notifications.create(
          user: user,
          title: "【受診予定を新規登録しました】#{visit.hospital_name}",
          description: "日付： #{visit.visit_date.strftime("%-m月%-d日")}\n時間：#{visit.appointed_at.strftime("%H:%M")}\n目的：#{visit.purpose}",
          due_date: Date.current,
          is_sent: false
        )
      end

      let(:mail) { NotificationMailer.immediate_notification(notification) }

      it "件名、宛先、送信元が正しい" do
        expect(mail.subject).to eq("【受診予定を新規登録しました】東京病院")
        expect(mail.to).to eq([ "test@example.com" ])
        expect(mail.from).to eq([ "no-reply@yorisoi-note.com" ])
      end

      it "本文にユーザー名、病院名、日時、目的が含まれている" do
        expect(mail.body.encoded).to include("田中太郎")
        expect(mail.body.encoded).to include("東京病院")
        expect(mail.body.encoded).to include("診療科")
        expect(mail.body.encoded).to include("受診目的： 検査")
        expect(mail.body.encoded).to include("予約時間：")
      end
    end
  end

  describe "リマインド通知メール" do
    context "受診日前日にリマインド通知を送る場合" do
      let(:user) { create(:user, name: "田中太郎", email: "test@example.com") }
      let(:department) { create(:department, name: "内科") }

      let(:visit) do
        create(:visit,
          user: user,
          department: department,
          hospital_name: "東京病院",
          purpose: "検査",
          visit_date: Date.tomorrow,
          appointed_at: Time.zone.now.change(hour: 10, min: 0)
          )
      end

      # 前日リマインド通知を作成する
      let(:notification) do
        visit.notifications.create(
          user: user,
          title: "【リマインダー】#{visit.hospital_name}の受診予定",
          description: "明日が受診予定日ですので、ご案内いたします。\n時間：#{visit.appointed_at.strftime("%H:%M")}\n目的：#{visit.purpose}",
          due_date: visit.visit_date - 1.day,
          is_sent: false
        )
      end

      let(:mail) { NotificationMailer.visit_reminder(notification) }

      it "件名、宛先、送信元が正しい" do
        expect(mail.subject).to eq("【リマインダー】東京病院の受診予定")
        expect(mail.body.encoded).to include("田中太郎")
        expect(mail.body.encoded).to include("東京病院")
        expect(mail.body.encoded).to include("受診目的： 検査")
        expect(mail.body.encoded).to include("予約時間：")
      end
    end
  end
end
