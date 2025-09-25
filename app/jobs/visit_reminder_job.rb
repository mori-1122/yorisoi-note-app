class VisitReminderJob < ApplicationJob
  queue_as :default

  def perform
    target_date = Time.zone.tomorrow

    Notification.includes(:visit)
                .where(is_sent: false, due_date: target_date)
                .find_each do |notification|
      Notification.transaction do # トランザクション開始
        NotificationMailer.visit_reminder(notification).deliver_now!
        notification.update!(is_sent: true)
      end
    end
  end
end
