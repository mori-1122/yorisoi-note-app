class RemoveMemoIdFromVisits < ActiveRecord::Migration[8.0]
  def change
    remove_column :visits, :memo_id, :integer
  end
end
