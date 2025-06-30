class AddUniqueIndexToQuestionsContent < ActiveRecord::Migration[8.0]
  def change
    add_index :questions, [ :content, :department_id, :question_category_id ], unique: true # #同じ質問内容＋診療科＋カテゴリの組み合わせは重複できないようにする
  end
end
