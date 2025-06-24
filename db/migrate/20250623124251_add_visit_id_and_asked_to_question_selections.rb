class AddVisitIdAndAskedToQuestionSelections < ActiveRecord::Migration[8.0]
  def change
    add_column :question_selections, :visit_id, :bigint, null: false ## 「どの通院（visit）に対する質問か」を記録する
    add_column :question_selections, :asked, :boolean, default: false, null: false # #「この質問を実際に医師に聞けたかどうか」 初期値はfalse（まだ聞いていない）

    add_index :question_selections, [ :visit_id, :question_id ], unique: true ## 同じ質問を同じ通院予定に重複して登録できないようにするための制約 visit_idとquestion_idの組み合わせが一意
    add_foreign_key :question_selections, :visits ##visit_id は visits テーブルの id と外部キーでつながる
  end
end
