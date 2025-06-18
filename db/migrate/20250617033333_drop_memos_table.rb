class DropMemosTable < ActiveRecord::Migration[8.0]
  def change
    drop_table :memos do |t|
      t.references :visit, null: false, foreign_key: true
      t.text :content, null: false
      t.timestamps
    end
  end
end
