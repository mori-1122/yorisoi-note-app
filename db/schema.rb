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

ActiveRecord::Schema[8.0].define(version: 2025_06_29_111644) do
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

  create_table "question_categories", force: :cascade do |t|
    t.string "category_name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_name"], name: "index_question_categories_on_category_name", unique: true
  end

  create_table "question_selections", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "question_id", null: false
    t.datetime "selected_at", null: false ##どの質問を聞くか
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "visit_id", null: false ##どの診察で聞くか
    t.boolean "asked", default: false, null: false ##実際に「聞けたかどうか」
    t.index ["question_id"], name: "index_question_selections_on_question_id"
    t.index ["user_id"], name: "index_question_selections_on_user_id"
    t.index ["visit_id", "question_id"], name: "index_question_selections_on_visit_id_and_question_id", unique: true
  end

  create_table "questions", force: :cascade do |t|
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "department_id"
    t.bigint "question_category_id"
    t.index ["content", "question_category_id", "department_id"], name: "index_questions_on_content_add_category_and_department", unique: true
    t.index ["department_id"], name: "index_questions_on_department_id"
    t.index ["question_category_id"], name: "index_questions_on_question_category_id"
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
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token"
  end

  create_table "visits", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.date "visit_date", null: false
    t.string "hospital_name", null: false
    t.string "purpose", null: false
    t.boolean "has_recording"
    t.boolean "has_document"
    t.bigint "department_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "appointed_at", null: false
    t.text "memo"
    t.index ["department_id"], name: "index_visits_on_department_id"
    t.index ["user_id", "visit_date", "appointed_at"], name: "index_visits_on_user_date_time", unique: true
    t.index ["user_id"], name: "index_visits_on_user_id"
  end

  add_foreign_key "documents", "users"
  add_foreign_key "documents", "visits"
  add_foreign_key "notifications", "users"
  add_foreign_key "question_selections", "questions"
  add_foreign_key "question_selections", "users"
  add_foreign_key "question_selections", "visits"
  add_foreign_key "questions", "departments"
  add_foreign_key "questions", "question_categories"
  add_foreign_key "recordings", "users"
  add_foreign_key "recordings", "visits"
  add_foreign_key "visits", "departments"
  add_foreign_key "visits", "users"
end
