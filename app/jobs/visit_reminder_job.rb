class VisitReminderJob < ApplicationJob
  queue_as :default

  def perform
    # 翌日が受診予定の visit に紐づく通知を探してメール送信
    visits = Visit.where(visit_date: Time.zone.tomorrow).includes(:notifications)
    visits.find_each do |visit|  # ← Visitごとに処理
      notification = visit.notifications.find_by(is_sent: false) # 「未送信の通知」を1件探す

      if notification
        NotificationMailer.visit_reminder(notification).deliver_later
        notification.update!(is_sent: true)
      end
    end
  end
end
