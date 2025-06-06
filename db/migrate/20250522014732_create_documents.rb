class CreateDocuments < ActiveRecord::Migration[8.0]
  def change
    create_table :documents do |t|
      t.references :user, null: false, foreign_key: true
      t.references :visit, null: false, foreign_key: true
      t.string :image_path # #書類情報は任意 null許容
      t.string :doc_type
      t.datetime :taken_at

      t.timestamps
    end
  end
end
