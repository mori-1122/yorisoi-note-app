class AddNullFalseToNotificationsVisitId < ActiveRecord::Migration[8.0]
  def change
    change_column_null :notifications, :visit_id, false
  end
end
