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

ActiveRecord::Schema[8.1].define(version: 2026_10_14_030006) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.string "username", null: false
    t.string "display_name", null: false
    t.string "password_digest", null: false
    t.boolean "admin", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "active_character_id"
    t.index ["active_character_id"], name: "index_accounts_on_active_character_id"
    t.index ["username"], name: "index_accounts_on_username", unique: true
  end

  create_table "characters", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.bigint "room_id", null: false
    t.string "name", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "lower((name)::text)", name: "index_characters_on_lower_name", unique: true
    t.index ["account_id"], name: "index_characters_on_account_id"
    t.index ["room_id"], name: "index_characters_on_room_id"
  end

  create_table "exits", force: :cascade do |t|
    t.bigint "source_room_id", null: false
    t.bigint "destination_room_id", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["destination_room_id"], name: "index_exits_on_destination_room_id"
    t.index ["source_room_id", "name"], name: "index_exits_on_source_room_id_and_name", unique: true
    t.index ["source_room_id"], name: "index_exits_on_source_room_id"
  end

  create_table "ooc_messages", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_ooc_messages_on_account_id"
  end

  create_table "remembered_characters", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.bigint "character_id", null: false
    t.string "context_type", null: false
    t.bigint "context_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "context_type", "context_id"], name: "index_remembered_characters_on_account_and_context", unique: true
    t.index ["account_id"], name: "index_remembered_characters_on_account_id"
    t.index ["character_id"], name: "index_remembered_characters_on_character_id"
  end

  create_table "rooms", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.boolean "starting", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "sessions", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_sessions_on_account_id"
  end

  add_foreign_key "accounts", "characters", column: "active_character_id", on_delete: :nullify
  add_foreign_key "characters", "accounts"
  add_foreign_key "characters", "rooms"
  add_foreign_key "exits", "rooms", column: "destination_room_id"
  add_foreign_key "exits", "rooms", column: "source_room_id"
  add_foreign_key "ooc_messages", "accounts"
  add_foreign_key "remembered_characters", "accounts"
  add_foreign_key "remembered_characters", "characters", on_delete: :cascade
  add_foreign_key "sessions", "accounts"
end
