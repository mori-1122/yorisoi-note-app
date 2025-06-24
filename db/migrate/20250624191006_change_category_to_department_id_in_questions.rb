class ChangeCategoryToDepartmentIdInQuestions < ActiveRecord::Migration[8.0]
  def change
    remove_column :questions, :category, :string
    add_reference :questions, :department, null: false, foreign_key: true
  end
end
