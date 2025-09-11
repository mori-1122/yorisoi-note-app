class VisitReminderJob < ApplicationJob
  queue_as :default

  def perform
    # 翌日が受診予定の visit に紐づく通知を探してメール送信
    Visit.where(visit_date: Date.tomorrow).find_each do |visit|  # ← Visitごとに1回
      visit.notifications.each do |notification| # ← そのVisitに紐づく通知ごとに1回
        NotificationMailer.visit_reminder(notification).deliver_later
      end
    end
  end
end
