require "rails_helper"

RSpec.describe VisitReminderJob, type: :job do
  describe "#perform" do
    it "翌日が期限の通知に対してリマインドメールを送信する" do
      # モックの準備
      target_date = Time.zone.tomorrow
      notification = create(:notification, due_date: target_date, is_sent: false)

      # NotificationMailer.visit_reminderが返す
      # ActionMailer::MessageDelivery のインスタンスダブルを作成
      mailer_mock = instance_double(ActionMailer::MessageDelivery)

      allow(NotificationMailer).to receive(:visit_reminder)
        .with(notification)
        .and_return(mailer_mock)
      allow(mailer_mock).to receive(:deliver_now!)

      # 実行する
      described_class.new.perform

      # 検証する
      expect(NotificationMailer).to have_received(:visit_reminder).with(notification)
      expect(mailer_mock).to have_received(:deliver_now!)
    end

    it "送信後に通知を送信すみに記録する" do
      # 準備
      target_date = Time.zone.tomorrow
      notification = create(:notification, due_date: target_date, is_sent: false)

      allow(NotificationMailer).to receive_message_chain(:visit_reminder, :deliver_now!)

      # 実行
      described_class.new.perform

      # 検証
      expect(notification.reload.is_sent).to eq(true)
    end

    it "受診予定日が翌日でない場合は送信しない" do
      # 準備
      notification = create(:notification, due_date: Time.zone.today, is_sent: false)

      allow(NotificationMailer).to receive(:visit_reminder)

      # 実行
      described_class.new.perform

      # 検証
      expect(NotificationMailer).not_to have_received(:visit_reminder)
      expect(notification.reload.is_sent).to eq(false)
    end
  end
end
