namespace :notification do
  desc "翌日受診予定のユーザーにリマインド通知を送る（検証）"

  task send_remind: :environment do
    Visit.where(visit_date: Time.zone.tomorrow).includes(:notifications).find_each do |visit|
      visit.notifications.each do |notification|
        NotificationMailer.visit_reminder(notification).deliver_now
      end
    end
    puts "テスト完了"
  end
end
