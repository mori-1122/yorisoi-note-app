class AddAppointedAtToVisits < ActiveRecord::Migration[8.0]
  def change
    add_column :visits, :appointed_at, :datetime, null: false
  end
end
