class VisitMailer < ApplicationMailer
  def reminder
    @visit = params[:visit]
    @user = @visit.user
    mail(
      to:
      @user.email,
      subject: "【リマインダー】#{@visit.hospital_name}の受診予定")
  end
end
