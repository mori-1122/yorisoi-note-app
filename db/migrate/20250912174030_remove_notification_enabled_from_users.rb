class RemoveNotificationEnabledFromUsers < ActiveRecord::Migration[8.0]
  def change
    remove_column :users, :notification_enabled, :boolean
  end
end
