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

ActiveRecord::Schema[7.0].define(version: 2023_02_24_130155) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "conversations", force: :cascade do |t|
    t.bigint "user1_id", null: false
    t.bigint "user2_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user1_id"], name: "index_conversations_on_user1_id"
    t.index ["user2_id"], name: "index_conversations_on_user2_id"
  end

  create_table "faculties", force: :cascade do |t|
    t.string "faculty_name", null: false
    t.bigint "university_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["university_id"], name: "index_faculties_on_university_id"
  end

  create_table "faculties_to_meet", id: false, force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "faculty_id", null: false
    t.index ["faculty_id", "user_id"], name: "index_faculties_to_meet_on_faculty_id_and_user_id"
    t.index ["user_id", "faculty_id"], name: "index_faculties_to_meet_on_user_id_and_faculty_id"
  end

  create_table "favourites", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "story_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["story_id"], name: "index_favourites_on_story_id"
    t.index ["user_id"], name: "index_favourites_on_user_id"
  end

  create_table "meets", force: :cascade do |t|
    t.bigint "user1_id", null: false
    t.bigint "user2_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user1_id"], name: "index_meets_on_user1_id"
    t.index ["user2_id"], name: "index_meets_on_user2_id"
  end

  create_table "messages", force: :cascade do |t|
    t.bigint "conversation_id", null: false
    t.bigint "user_id", null: false
    t.text "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["conversation_id"], name: "index_messages_on_conversation_id"
    t.index ["user_id"], name: "index_messages_on_user_id"
  end

  create_table "stories", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "faculty_id", null: false
    t.string "body", null: false
    t.string "background_gradient", null: false
    t.boolean "favourites", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["faculty_id"], name: "index_stories_on_faculty_id"
    t.index ["user_id"], name: "index_stories_on_user_id"
  end

  create_table "studies", force: :cascade do |t|
    t.string "name", null: false
    t.integer "courses", null: false
    t.bigint "faculty_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["faculty_id"], name: "index_studies_on_faculty_id"
  end

  create_table "universities", force: :cascade do |t|
    t.string "name", null: false
    t.string "simple_name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "uid", null: false
    t.string "cloud_token"
    t.string "name", null: false
    t.integer "sex", null: false
    t.integer "age", null: false
    t.string "profile_image"
    t.string "meet_picture"
    t.bigint "university_id", null: false
    t.bigint "faculty_id", null: false
    t.bigint "study_id", null: false
    t.boolean "meet_status", null: false
    t.integer "sex_to_meet", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["faculty_id"], name: "index_users_on_faculty_id"
    t.index ["study_id"], name: "index_users_on_study_id"
    t.index ["university_id"], name: "index_users_on_university_id"
  end

  add_foreign_key "conversations", "users", column: "user1_id"
  add_foreign_key "conversations", "users", column: "user2_id"
  add_foreign_key "faculties", "universities"
  add_foreign_key "favourites", "stories"
  add_foreign_key "favourites", "users"
  add_foreign_key "meets", "users", column: "user1_id"
  add_foreign_key "meets", "users", column: "user2_id"
  add_foreign_key "messages", "conversations"
  add_foreign_key "messages", "users"
  add_foreign_key "stories", "faculties"
  add_foreign_key "stories", "users"
  add_foreign_key "studies", "faculties"
  add_foreign_key "users", "faculties"
  add_foreign_key "users", "studies"
  add_foreign_key "users", "universities"
end
