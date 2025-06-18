class AddUniqueConstraintToVisits < ActiveRecord::Migration[8.0]
  def change
    add_index :visits, [ :user_id, :visit_date, :appointed_at ], unique: true, name: "index_visits_on_user_date_time"
  end
end
