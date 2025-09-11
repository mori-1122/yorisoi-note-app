class AddVisitIdToNotifications < ActiveRecord::Migration[8.0]
  def change
    add_reference :notifications, :visit, foreign_key: true
  end
end
