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

ActiveRecord::Schema[7.0].define(version: 2023_03_13_225041) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "bookmarks", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "flat_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["flat_id"], name: "index_bookmarks_on_flat_id"
    t.index ["user_id"], name: "index_bookmarks_on_user_id"
  end

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

  create_table "faculties_users", id: false, force: :cascade do |t|
    t.bigint "faculty_id"
    t.bigint "user_id"
    t.index ["faculty_id", "user_id"], name: "index_faculties_users_on_faculty_id_and_user_id", unique: true
    t.index ["faculty_id"], name: "index_faculties_users_on_faculty_id"
    t.index ["user_id"], name: "index_faculties_users_on_user_id"
  end

  create_table "favourites", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "story_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["story_id"], name: "index_favourites_on_story_id"
    t.index ["user_id"], name: "index_favourites_on_user_id"
  end

  create_table "features", force: :cascade do |t|
    t.string "name", null: false
    t.integer "icon", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "flats", force: :cascade do |t|
    t.bigint "owner_id", null: false
    t.string "title", null: false
    t.string "description", null: false
    t.point "geometry", null: false
    t.integer "currency", null: false
    t.integer "rent_price_per_month_in_cents", null: false
    t.integer "advance_price_in_cents", null: false
    t.integer "electricity_price_in_cents", null: false
    t.datetime "available_from", null: false
    t.decimal "max_months_stay", null: false
    t.decimal "min_months_stay", null: false
    t.string "tenants_number", null: false
    t.string "bedroom", null: false
    t.string "bathroom", null: false
    t.integer "built", null: false
    t.integer "floor", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "images", default: [], array: true
    t.index ["owner_id"], name: "index_flats_on_owner_id"
  end

  create_table "flats_features", id: false, force: :cascade do |t|
    t.bigint "flat_id"
    t.bigint "feature_id"
    t.index ["feature_id"], name: "index_flats_features_on_feature_id"
    t.index ["flat_id", "feature_id"], name: "index_flats_features_on_flat_id_and_feature_id", unique: true
    t.index ["flat_id"], name: "index_flats_features_on_flat_id"
  end

  create_table "flats_tenants", id: false, force: :cascade do |t|
    t.bigint "flat_id"
    t.bigint "user_id"
    t.index ["flat_id", "user_id"], name: "index_flats_tenants_on_flat_id_and_user_id", unique: true
    t.index ["flat_id"], name: "index_flats_tenants_on_flat_id"
    t.index ["user_id"], name: "index_flats_tenants_on_user_id"
  end

  create_table "flats_transports", id: false, force: :cascade do |t|
    t.bigint "flat_id"
    t.bigint "transport_id"
    t.index ["flat_id", "transport_id"], name: "index_flats_transports_on_flat_id_and_transport_id", unique: true
    t.index ["flat_id"], name: "index_flats_transports_on_flat_id"
    t.index ["transport_id"], name: "index_flats_transports_on_transport_id"
  end

  create_table "flats_universities", id: false, force: :cascade do |t|
    t.bigint "flat_id"
    t.bigint "university_id"
    t.index ["flat_id", "university_id"], name: "index_flats_universities_on_flat_id_and_university_id", unique: true
    t.index ["flat_id"], name: "index_flats_universities_on_flat_id"
    t.index ["university_id"], name: "index_flats_universities_on_university_id"
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
    t.datetime "creation_date", null: false
    t.text "body"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["conversation_id"], name: "index_messages_on_conversation_id"
    t.index ["user_id"], name: "index_messages_on_user_id"
  end

  create_table "properties", force: :cascade do |t|
    t.bigint "flat_id", null: false
    t.string "country", null: false
    t.string "city", null: false
    t.string "countrycode", null: false
    t.string "postcode", null: false
    t.string "county"
    t.string "housenumber"
    t.string "name", null: false
    t.string "state", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["flat_id"], name: "index_properties_on_flat_id"
  end

  create_table "stories", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "faculty_id", null: false
    t.string "body", null: false
    t.integer "background_gradient_index", null: false
    t.datetime "creation_date", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["faculty_id"], name: "index_stories_on_faculty_id"
    t.index ["user_id"], name: "index_stories_on_user_id"
  end

  create_table "studies", force: :cascade do |t|
    t.string "study_name", null: false
    t.bigint "faculty_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["faculty_id"], name: "index_studies_on_faculty_id"
  end

  create_table "transports", force: :cascade do |t|
    t.string "name", null: false
    t.integer "icon", null: false
    t.integer "minutes", null: false
    t.bigint "university_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["university_id"], name: "index_transports_on_university_id"
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
    t.string "email", null: false
    t.integer "sex", null: false
    t.integer "age", null: false
    t.string "profile_image"
    t.string "meet_picture"
    t.bigint "university_id", null: false
    t.bigint "faculty_id", null: false
    t.bigint "study_id", null: false
    t.boolean "meet_status", null: false
    t.integer "sex_to_meet", null: false
    t.bigint "university_to_meet_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["faculty_id"], name: "index_users_on_faculty_id"
    t.index ["study_id"], name: "index_users_on_study_id"
    t.index ["university_id"], name: "index_users_on_university_id"
    t.index ["university_to_meet_id"], name: "index_users_on_university_to_meet_id"
  end

  create_table "visualizations", force: :cascade do |t|
    t.bigint "story_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["story_id"], name: "index_visualizations_on_story_id"
    t.index ["user_id"], name: "index_visualizations_on_user_id"
  end

  add_foreign_key "bookmarks", "flats"
  add_foreign_key "bookmarks", "users"
  add_foreign_key "conversations", "users", column: "user1_id"
  add_foreign_key "conversations", "users", column: "user2_id"
  add_foreign_key "faculties", "universities"
  add_foreign_key "favourites", "stories"
  add_foreign_key "favourites", "users"
  add_foreign_key "flats", "users", column: "owner_id"
  add_foreign_key "meets", "users", column: "user1_id"
  add_foreign_key "meets", "users", column: "user2_id"
  add_foreign_key "messages", "conversations"
  add_foreign_key "messages", "users"
  add_foreign_key "properties", "flats"
  add_foreign_key "stories", "faculties"
  add_foreign_key "stories", "users"
  add_foreign_key "studies", "faculties"
  add_foreign_key "transports", "universities"
  add_foreign_key "users", "faculties"
  add_foreign_key "users", "studies"
  add_foreign_key "users", "universities"
  add_foreign_key "users", "universities", column: "university_to_meet_id"
  add_foreign_key "visualizations", "stories"
  add_foreign_key "visualizations", "users"
end
