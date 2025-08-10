class RemoveFilePathAndMemoFromRecordings < ActiveRecord::Migration[8.0]
  def change
    remove_column :recordings, :file_path, :string
    remove_column :recordings, :memo, :text
  end
end
