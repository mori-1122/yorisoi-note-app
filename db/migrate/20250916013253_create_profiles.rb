class CreateProfiles < ActiveRecord::Migration[8.0]
  def change
    create_table :profiles do |t|
      t.references :user, null: false, foreign_key: true
      t.date :birthday, null: false
      t.integer :gender, null: false
      t.integer :height
      t.integer :weight
      t.string :blood_type, default: "不明"
      t.text :allergy_details, default: ""
      t.text :medical_history, default: ""
      t.text :current_medication, default: ""

      t.timestamps
    end
  end
end
