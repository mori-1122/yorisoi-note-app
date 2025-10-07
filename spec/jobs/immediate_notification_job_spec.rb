require "rails_helper"

RSpec.describe ImmediateNotificationJob, type: :job do
  describe "#perform" do
    it "即時メールを送信する" do
      # モックの準備
      notification = create(:notification)

      # NotificationMailerのモックを作成
      mailer_mock = double("NotificationMailer")

      # クラスにモックを仕込んだ後に、immediate_notificationの呼び出しを差し替えてモックする
      allow(NotificationMailer).to receive(:immediate_notification)
        .with(notification)
        .and_return(mailer_mock)

      # deliver_now!が呼ばれても何もしない
      allow(mailer_mock).to receive(:deliver_now!)

      # job実行
      described_class.new.perform(notification.id)

      # 検証する
      expect(NotificationMailer).to have_received(:immediate_notification).with(notification)
      expect(mailer_mock).to have_received(:deliver_now!)
    end

    it "送信後に通知を送信すみに記録する" do
      # 準備
      notification = create(:notification, is_sent: false)

      # メール送信部分をモックで差し替え
      allow(NotificationMailer).to receive_message_chain(:immediate_notification, :deliver_now!)

      # job実行
      described_class.new.perform(notification.id)

      # 検証する
      expect(notification.reload.is_sent).to eq(true)
    end
  end
end
