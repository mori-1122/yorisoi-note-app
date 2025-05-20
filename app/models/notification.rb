class Notification < ApplicationRecord
  belongs_to :user # #1人のユーザに属している

  validates :title, presence: true # #title必須 空だと保存できない
  validates :due_date, presence: true # #通知の期限日必須　 空だと保存できない
end
