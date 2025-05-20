class CreateRecordings < ActiveRecord::Migration[8.0]
  def change
    create_table :recordings do |t|
      t.references :user, null: false, foreign_key: true
      t.references :visit, null: false, foreign_key: true
      t.string :file_path
      t.text :memo
      t.datetime :recorded_at

      t.timestamps
    end
  end
end
