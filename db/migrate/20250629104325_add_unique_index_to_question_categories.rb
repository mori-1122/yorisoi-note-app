class AddUniqueIndexToQuestionCategories < ActiveRecord::Migration[8.0]
  def change
    add_index :question_categories, :category_name, unique: true
  end
end
