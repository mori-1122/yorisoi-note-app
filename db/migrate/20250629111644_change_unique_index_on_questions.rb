class ChangeUniqueIndexOnQuestions < ActiveRecord::Migration[8.0]
  def change
    # content 単体のユニークインデックスを削除
    remove_index :questions, name: "index_questions_on_content"

    add_index :questions, [ :content, :question_category_id, :department_id ], # #add_indexに複合キー指定
              unique: true,
              name: "index_questions_on_content_add_category_and_department"
  end
end
