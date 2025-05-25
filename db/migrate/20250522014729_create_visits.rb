class CreateVisits < ActiveRecord::Migration[8.0]
  def change
    create_table :visits do |t|
      t.references :user, null: false, foreign_key: true
      t.date :visit_date, null: false
      t.string :hospital_name, null: false
      t.string :purpose, null: false
      t.boolean :has_recording # #任意なので null可
      t.boolean :has_document # #任意なので null可
      t.integer :memo_id # #任意なので null可
      t.references :department, null: true, foreign_key: true

      t.timestamps
    end
  end
end
