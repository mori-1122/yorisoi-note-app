class NotificationMailer < ApplicationMailer
  # 受診予定登録直後に送られる
  def created(notification)
    @notification = notification
    @visit = notification.visit

    mail(
      to: @notification.user.email,
      subject: "【受診予定を新規登録しました】#{@visit.hospital_name}"
    )
  end

  def visit_reminder(notification)
    @notification = notification
    @visit = notification.visit
    mail(
      to:
      @notification.user.email,
      subject: "【リマインダー】#{@visit.hospital_name}の受診予定"
      )
  end
end
