class AddQuestionCategoryToQuestions < ActiveRecord::Migration[8.0]
  def change
    add_reference :questions, :question_category, null: false, foreign_key: true
  end
end
