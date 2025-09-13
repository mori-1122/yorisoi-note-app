namespace :notification do
  desc "翌日受診予定のユーザーにリマインド通知を送る（検証）"

  task send_remind: :environment do
    puts "テストraketask"
  end
end
