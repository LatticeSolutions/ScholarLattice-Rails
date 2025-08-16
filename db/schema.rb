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

ActiveRecord::Schema[8.0].define(version: 2025_08_16_145446) do
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
    t.boolean "show_events", default: true, null: false
    t.boolean "registerable", default: false, null: false
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
    t.uuid "attached_page_id"
    t.uuid "attached_collection_id"
    t.string "webinar_link"
    t.index ["ancestry"], name: "index_events_on_ancestry"
    t.index ["attached_collection_id"], name: "index_events_on_attached_collection_id", unique: true
    t.index ["attached_page_id"], name: "index_events_on_attached_page_id", unique: true
    t.index ["collection_id"], name: "index_events_on_collection_id"
    t.index ["submission_id"], name: "index_events_on_submission_id", unique: true
  end

  create_table "invitations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "profile_id", null: false
    t.uuid "collection_id", null: false
    t.integer "status", default: 0, null: false
    t.text "message"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["collection_id"], name: "index_invitations_on_collection_id"
    t.index ["profile_id"], name: "index_invitations_on_profile_id"
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

  create_table "registration_options", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.integer "cost"
    t.datetime "opens_on"
    t.datetime "closes_on"
    t.integer "stock"
    t.uuid "collection_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "auto_accept", default: false, null: false
    t.string "allowed_domains"
    t.index ["collection_id"], name: "index_registration_options_on_collection_id"
  end

  create_table "registration_payments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "amount", default: 0, null: false
    t.text "memo"
    t.uuid "registration_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "external_id"
    t.index ["registration_id"], name: "index_registration_payments_on_registration_id"
  end

  create_table "registrations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "status", default: 0, null: false
    t.uuid "registration_option_id", null: false
    t.uuid "profile_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["profile_id"], name: "index_registrations_on_profile_id"
    t.index ["registration_option_id"], name: "index_registrations_on_registration_option_id"
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
    t.string "private_notes"
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
  add_foreign_key "events", "collections", column: "attached_collection_id"
  add_foreign_key "events", "pages", column: "attached_page_id"
  add_foreign_key "events", "submissions"
  add_foreign_key "invitations", "collections"
  add_foreign_key "invitations", "profiles"
  add_foreign_key "likes", "collections"
  add_foreign_key "likes", "users"
  add_foreign_key "pages", "collections"
  add_foreign_key "profiles_users", "profiles"
  add_foreign_key "profiles_users", "users"
  add_foreign_key "registration_options", "collections"
  add_foreign_key "registration_payments", "registrations"
  add_foreign_key "registrations", "profiles"
  add_foreign_key "registrations", "registration_options"
  add_foreign_key "submissions", "collections"
  add_foreign_key "submissions", "profiles"
end
