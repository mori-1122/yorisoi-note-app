class NotificationMailer < ApplicationMailer
  def visit_reminder(notification)
    @notification = notification
    mail(
      to:
      @notification.user.email,
      subject: "【リマインダー】#{@notification.title}の受診予定"
      )
  end
end
