class AddMemoToVisits < ActiveRecord::Migration[8.0]
  def change
    add_column :visits, :memo, :text
  end
end
