class ChangeDepartmentIdNullableInVisits < ActiveRecord::Migration[8.0]
  def change
    change_column_null :visits, :department_id, true
  end
end
