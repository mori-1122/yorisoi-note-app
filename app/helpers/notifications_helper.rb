module NotificationsHelper
  # 受診予定日を「YYYY年M月D日」形式で表示
  def format_due_date(date)
    return "未定" if date.blank?
    date.strftime("%Y年%-m月%d日")
  end

  # 通知の送信状態を日本語で表示
  def display_send_status(is_sent)
    is_sent ? "送信済み" : "未送信"
  end
end
