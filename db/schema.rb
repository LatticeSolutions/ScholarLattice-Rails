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

ActiveRecord::Schema[8.0].define(version: 2025_02_24_015811) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "admins", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "collection_id"
    t.uuid "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["collection_id"], name: "index_admins_on_collection_id"
    t.index ["user_id"], name: "index_admins_on_user_id"
  end

  create_table "collections", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "title"
    t.string "short_title"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "ancestry", default: "/", null: false, collation: "C"
    t.string "subcollection_name", default: "Subcollection", null: false
    t.timestamptz "submissions_open_on"
    t.timestamptz "submissions_close_on"
    t.boolean "submittable"
    t.string "time_zone"
    t.integer "order"
    t.index ["ancestry"], name: "index_collections_on_ancestry"
  end

  create_table "events", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "title", default: "Untitled Event", null: false
    t.text "description"
    t.string "location"
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.uuid "collection_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "ancestry", default: "/", null: false, collation: "C"
    t.uuid "submission_id"
    t.integer "order"
    t.index ["ancestry"], name: "index_events_on_ancestry"
    t.index ["collection_id"], name: "index_events_on_collection_id"
    t.index ["submission_id"], name: "index_events_on_submission_id", unique: true
  end

  create_table "likes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.uuid "collection_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["collection_id"], name: "index_likes_on_collection_id"
    t.index ["user_id"], name: "index_likes_on_user_id"
  end

  create_table "pages", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "title", default: "New Page", null: false
    t.text "content", default: "Page content goes here.", null: false
    t.uuid "collection_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_home", default: false
    t.integer "visibility", default: 2
    t.integer "order"
    t.index ["collection_id"], name: "index_pages_on_collection_id"
  end

  create_table "passwordless_sessions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "authenticatable_type"
    t.uuid "authenticatable_id"
    t.datetime "timeout_at", precision: nil, null: false
    t.datetime "expires_at", precision: nil, null: false
    t.datetime "claimed_at", precision: nil
    t.string "token_digest", null: false
    t.string "identifier", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["authenticatable_type", "authenticatable_id"], name: "authenticatable"
    t.index ["identifier"], name: "index_passwordless_sessions_on_identifier", unique: true
  end

  create_table "profiles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.string "email", null: false
    t.string "affiliation"
    t.string "position"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "position_type", default: 0
  end

  create_table "profiles_users", id: false, force: :cascade do |t|
    t.uuid "user_id", null: false
    t.uuid "profile_id", null: false
    t.index ["profile_id"], name: "index_profiles_users_on_profile_id"
    t.index ["user_id"], name: "index_profiles_users_on_user_id"
  end

  create_table "submissions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "title"
    t.text "abstract"
    t.text "notes"
    t.uuid "profile_id", null: false
    t.uuid "collection_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status", default: 0
    t.index ["collection_id"], name: "index_submissions_on_collection_id"
    t.index ["profile_id"], name: "index_submissions_on_profile_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "site_admin", default: false, null: false
    t.index "lower((email)::text)", name: "index_users_on_lowercase_email", unique: true
  end

  add_foreign_key "events", "collections"
  add_foreign_key "events", "submissions"
  add_foreign_key "likes", "collections"
  add_foreign_key "likes", "users"
  add_foreign_key "pages", "collections"
  add_foreign_key "profiles_users", "profiles"
  add_foreign_key "profiles_users", "users"
  add_foreign_key "submissions", "collections"
  add_foreign_key "submissions", "profiles"
end
