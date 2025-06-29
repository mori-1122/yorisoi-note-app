class FixUniqueIndexOnQuestionsContent < ActiveRecord::Migration[8.0]
  def change
    remove_index :questions, [ :content, :department_id, :question_category_id ]
    add_index :questions, :content, unique: true
  end
end
