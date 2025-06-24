class CreateQuestionCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :question_categories do |t|
      t.string :category_name, null: false

      t.timestamps
    end
  end
end
