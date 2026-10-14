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

ActiveRecord::Schema[8.1].define(version: 2026_10_14_070001) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "accounts", force: :cascade do |t|
    t.string "username", null: false
    t.string "display_name", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "active_character_id"
    t.string "email"
    t.integer "staff_level", default: 0, null: false
    t.boolean "founder", default: false, null: false
    t.boolean "storyteller", default: false, null: false
    t.string "job_flags", default: [], null: false, array: true
    t.string "email_notifications", default: "off", null: false
    t.index "lower((email)::text)", name: "index_accounts_on_lower_email", unique: true, where: "(email IS NOT NULL)"
    t.index ["active_character_id"], name: "index_accounts_on_active_character_id"
    t.index ["username"], name: "index_accounts_on_username", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "areas", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.bigint "parent_id"
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "entrance_room_id"
    t.index ["entrance_room_id"], name: "index_areas_on_entrance_room_id"
    t.index ["parent_id"], name: "index_areas_on_parent_id"
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

  create_table "game_settings", force: :cascade do |t|
    t.boolean "email_required", default: true, null: false
    t.boolean "approval_required", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "auto_skip", default: true, null: false
    t.integer "turn_minutes", default: 5, null: false
  end

  create_table "ooc_messages", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_ooc_messages_on_account_id"
  end

  create_table "poses", force: :cascade do |t|
    t.bigint "scene_id", null: false
    t.bigint "character_id"
    t.string "kind", default: "passage", null: false
    t.text "body", null: false
    t.text "original_body"
    t.integer "sequence", null: false
    t.datetime "edited_at"
    t.datetime "removed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["character_id"], name: "index_poses_on_character_id"
    t.index ["scene_id", "sequence"], name: "index_poses_on_scene_id_and_sequence", unique: true
    t.index ["scene_id"], name: "index_poses_on_scene_id"
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
    t.bigint "area_id", null: false
    t.index ["area_id"], name: "index_rooms_on_area_id"
  end

  create_table "scene_invitations", force: :cascade do |t|
    t.bigint "scene_id", null: false
    t.bigint "character_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["character_id"], name: "index_scene_invitations_on_character_id"
    t.index ["scene_id", "character_id"], name: "index_scene_invitations_on_scene_id_and_character_id", unique: true
    t.index ["scene_id"], name: "index_scene_invitations_on_scene_id"
  end

  create_table "scene_participants", force: :cascade do |t|
    t.bigint "scene_id", null: false
    t.bigint "character_id", null: false
    t.string "role", default: "player", null: false
    t.integer "position", null: false
    t.integer "last_read_sequence", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["character_id"], name: "index_scene_participants_on_character_id"
    t.index ["scene_id", "character_id"], name: "index_scene_participants_on_scene_id_and_character_id", unique: true
    t.index ["scene_id"], name: "index_scene_participants_on_scene_id"
  end

  create_table "scenes", force: :cascade do |t|
    t.bigint "room_id", null: false
    t.string "title", null: false
    t.string "visibility", default: "joinable", null: false
    t.string "pose_mode", default: "turns", null: false
    t.boolean "auto_skip", default: true, null: false
    t.integer "turn_minutes", default: 5, null: false
    t.bigint "current_turn_participant_id"
    t.datetime "turn_started_at"
    t.datetime "turn_warned_at"
    t.integer "turn_token", default: 0, null: false
    t.integer "last_sequence", default: 0, null: false
    t.datetime "last_pose_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["last_pose_at"], name: "index_scenes_on_last_pose_at"
    t.index ["room_id"], name: "index_scenes_on_room_id"
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
  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "areas", "areas", column: "parent_id"
  add_foreign_key "areas", "rooms", column: "entrance_room_id", on_delete: :nullify
  add_foreign_key "characters", "accounts"
  add_foreign_key "characters", "rooms"
  add_foreign_key "exits", "rooms", column: "destination_room_id"
  add_foreign_key "exits", "rooms", column: "source_room_id"
  add_foreign_key "ooc_messages", "accounts"
  add_foreign_key "poses", "characters"
  add_foreign_key "poses", "scenes"
  add_foreign_key "remembered_characters", "accounts"
  add_foreign_key "remembered_characters", "characters", on_delete: :cascade
  add_foreign_key "rooms", "areas"
  add_foreign_key "scene_invitations", "characters"
  add_foreign_key "scene_invitations", "scenes"
  add_foreign_key "scene_participants", "characters"
  add_foreign_key "scene_participants", "scenes"
  add_foreign_key "scenes", "rooms"
  add_foreign_key "scenes", "scene_participants", column: "current_turn_participant_id", on_delete: :nullify
  add_foreign_key "sessions", "accounts"
end
