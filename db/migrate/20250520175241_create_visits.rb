class CreateVisits < ActiveRecord::Migration[8.0]
  def change
    create_table :visits do |t|
      t.references :user, null: false, foreign_key: true
      t.date :visit_date
      t.string :hospital_name
      t.string :purpose
      t.boolean :has_recording
      t.boolean :has_document
      t.integer :memo_id
      t.timestamps
    end
  end
end
