class CreateQuestions < ActiveRecord::Migration[8.0]
  def change
    create_table :questions do |t|
      t.string :category
      t.text :content

      t.timestamps
    end
  end
end
