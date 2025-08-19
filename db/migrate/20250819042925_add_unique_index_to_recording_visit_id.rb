class AddUniqueIndexToRecordingVisitId < ActiveRecord::Migration[8.0]
  def change
    remove_index :recordings, :visit_id if index_exists?(:recordings, :visit_id)
    add_index :recordings, :visit_id, unique: true
  end
end
