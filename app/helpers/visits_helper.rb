module VisitsHelper
  # 日時を2025年１０月９日形式で表示
  def format_visit_date(date)
    return "未定" if date.blank?
    date.strftime("%Y年%-m月%-d日")
  end

  # 　時刻をHH:MM形式で表示
  def format_appointed_time(time)
    return "--:--" if time.blank?
    time.strftime("%H:%M")
  end

  # 病院名表示
  def display_hospital_name(name)
    name.presence || "(未登録)"
  end
end
