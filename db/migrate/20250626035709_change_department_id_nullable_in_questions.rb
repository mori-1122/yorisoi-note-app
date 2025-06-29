class ChangeDepartmentIdNullableInQuestions < ActiveRecord::Migration[8.0]
  def change
    change_column_null :questions, :department_id, true
  end
end
