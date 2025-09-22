class ImmediateNotificationJob < ApplicationJob
  queue_as :default

  def perform(notification_id)
    notification = Notification.find(notification_id)

    Notification.transaction do
      # Jobそのものが非同期なので、deliver_nowを使用して即時に送る
      NotificationMailer.immediate_notification(notification).deliver_now
      notification.update!(is_sent: true)
    end
  end
end
