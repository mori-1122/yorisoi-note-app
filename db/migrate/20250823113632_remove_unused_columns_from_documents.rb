class RemoveUnusedColumnsFromDocuments < ActiveRecord::Migration[8.0]
  def change
    remove_column :documents, :image_path, :string
    remove_column :documents, :taken_at, :datetime
  end
end
