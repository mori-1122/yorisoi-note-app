class NotificationMailer < ApplicationMailer
  # 受診予定登録直後に送られる
  def immediate_notification(notification)
    @notification = notification
    @visit = notification.visit

    mail(
      to: @notification.user.email,
      subject: "【受診予定を新規登録しました】#{@visit.hospital_name}"
    ) do |format|
      format.html
    end
  end

  def visit_reminder(notification)
    @notification = notification
    @visit = notification.visit

    mail(
      to: @notification.user.email,
      subject: "【リマインダー】#{@visit.hospital_name}の受診予定"
    ) do |format|
      format.html
    end
  end
end
