class CreateNotifications < ActiveRecord::Migration[8.0]
  def change
    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.string :title
      t.text :description
      t.date :due_date
      t.boolean :is_sent, default: false, null: false
      t.timestamps
    end
  end
end
