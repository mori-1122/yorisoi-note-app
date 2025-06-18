class RemoveDoctorNameFromVisits < ActiveRecord::Migration[8.0]
  def change
    remove_column :visits, :doctor_name, :string
  end
end
