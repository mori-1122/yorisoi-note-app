class ChangeQuestionCategoryIdNullableInQuestions < ActiveRecord::Migration[8.0]
  def change
    change_column_null :questions, :question_category_id, true
  end
end
