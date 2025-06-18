class RemoveUserIdMemos < ActiveRecord::Migration[8.0]
  def change
    remove_column :memos, :user_id, :bigint
  end
end
