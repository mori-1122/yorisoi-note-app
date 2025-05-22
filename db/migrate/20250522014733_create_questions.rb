class CreateQuestions < ActiveRecord::Migration[8.0]
  def change
    create_table :questions do |t|
      t.string :category, null: false
      t.text :content, null: false

      t.timestamps
    end
  end
end
