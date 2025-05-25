# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_05_24_173959) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "departments", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "documents", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "visit_id", null: false
    t.string "image_path"
    t.string "doc_type"
    t.datetime "taken_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_documents_on_user_id"
    t.index ["visit_id"], name: "index_documents_on_visit_id"
  end

  create_table "memos", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "visit_id", null: false
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_memos_on_user_id"
    t.index ["visit_id"], name: "index_memos_on_visit_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "title", null: false
    t.text "description"
    t.date "due_date", null: false
    t.boolean "is_sent", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "question_selections", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "question_id", null: false
    t.datetime "selected_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["question_id"], name: "index_question_selections_on_question_id"
    t.index ["user_id"], name: "index_question_selections_on_user_id"
  end

  create_table "questions", force: :cascade do |t|
    t.string "category", null: false
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "recordings", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "visit_id", null: false
    t.string "file_path", null: false
    t.text "memo"
    t.datetime "recorded_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_recordings_on_user_id"
    t.index ["visit_id"], name: "index_recordings_on_visit_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "encrypted_password", null: false
    t.boolean "notification_enabled", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "visits", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.date "visit_date", null: false
    t.string "hospital_name", null: false
    t.string "purpose", null: false
    t.boolean "has_recording"
    t.boolean "has_document"
    t.integer "memo_id"
    t.bigint "department_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["department_id"], name: "index_visits_on_department_id"
    t.index ["user_id"], name: "index_visits_on_user_id"
  end

  add_foreign_key "documents", "users"
  add_foreign_key "documents", "visits"
  add_foreign_key "memos", "users"
  add_foreign_key "memos", "visits"
  add_foreign_key "notifications", "users"
  add_foreign_key "question_selections", "questions"
  add_foreign_key "question_selections", "users"
  add_foreign_key "recordings", "users"
  add_foreign_key "recordings", "visits"
  add_foreign_key "visits", "departments"
  add_foreign_key "visits", "users"
end
