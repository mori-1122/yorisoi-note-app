class UpdateVisitsTable < ActiveRecord::Migration[8.0]
  def change
    remove_column :visits, :doctor_name, :string
    add_column :visits, :appointed_at, :datetime, null: false
  end
end
