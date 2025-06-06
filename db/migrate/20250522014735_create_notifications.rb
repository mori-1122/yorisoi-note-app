class CreateNotifications < ActiveRecord::Migration[8.0]
  def change
    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.date :due_date, null: false
      t.boolean :is_sent, null: false, default: false

      t.timestamps
    end
  end
end
