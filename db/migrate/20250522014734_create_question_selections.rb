class CreateQuestionSelections < ActiveRecord::Migration[8.0]
  def change
    create_table :question_selections do |t|
      t.references :user, null: false, foreign_key: true
      t.references :question, null: false, foreign_key: true
      t.datetime :selected_at, null: false

      t.timestamps
    end
  end
end
