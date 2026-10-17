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

ActiveRecord::Schema[8.1].define(version: 2026_10_17_070000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "account_warnings", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.bigint "staff_id", null: false
    t.bigint "report_id"
    t.text "body", null: false
    t.datetime "read_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_account_warnings_on_account_id"
    t.index ["report_id"], name: "index_account_warnings_on_report_id"
    t.index ["staff_id"], name: "index_account_warnings_on_staff_id"
  end

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
    t.datetime "last_seen_at"
    t.integer "email_after_days", default: 3, null: false
    t.boolean "email_only_my_turn", default: false, null: false
    t.string "browser_notifications", default: "off", null: false
    t.integer "browser_notify_minutes", default: 5, null: false
    t.text "about_me"
    t.datetime "muted_until"
    t.boolean "system", default: false, null: false
    t.datetime "archived_at"
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

  create_table "alerts", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.bigint "character_id"
    t.bigint "scene_id"
    t.bigint "pose_id"
    t.string "kind", null: false
    t.integer "count", default: 1, null: false
    t.datetime "read_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "inkling_id"
    t.index ["account_id", "read_at"], name: "index_alerts_on_account_id_and_read_at"
    t.index ["account_id"], name: "index_alerts_on_account_id"
    t.index ["character_id"], name: "index_alerts_on_character_id"
    t.index ["inkling_id"], name: "index_alerts_on_inkling_id"
    t.index ["pose_id"], name: "index_alerts_on_pose_id"
    t.index ["scene_id"], name: "index_alerts_on_scene_id"
  end

  create_table "areas", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.bigint "parent_id"
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "entrance_room_id"
    t.string "summary"
    t.index ["entrance_room_id"], name: "index_areas_on_entrance_room_id"
    t.index ["parent_id"], name: "index_areas_on_parent_id"
  end

  create_table "bans", force: :cascade do |t|
    t.bigint "account_id"
    t.cidr "ip_range"
    t.text "reason", null: false
    t.bigint "banned_by_id", null: false
    t.datetime "expires_at"
    t.datetime "lifted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "chat_only", default: false, null: false
    t.index ["account_id"], name: "index_bans_on_account_id"
    t.index ["banned_by_id"], name: "index_bans_on_banned_by_id"
  end

  create_table "character_groups", force: :cascade do |t|
    t.string "name", null: false
    t.string "colour", default: "#5b3f8c", null: false
    t.string "description"
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "characters", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.bigint "room_id", null: false
    t.string "name", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "last_active_at"
    t.string "status", default: "approved", null: false
    t.datetime "submitted_at"
    t.datetime "reviewed_at"
    t.bigint "reviewed_by_id"
    t.text "review_note"
    t.integer "resonance", default: 0, null: false
    t.datetime "sheet_locked_at"
    t.datetime "retired_at"
    t.datetime "on_roster_at"
    t.text "roster_note"
    t.boolean "roster_when_idle", default: false, null: false
    t.datetime "roster_requested_at"
    t.bigint "character_group_id"
    t.boolean "gm", default: false, null: false
    t.datetime "roster_retired_at"
    t.index "lower((name)::text)", name: "index_characters_on_lower_name", unique: true
    t.index ["account_id"], name: "index_characters_on_account_id"
    t.index ["character_group_id"], name: "index_characters_on_character_group_id"
    t.index ["on_roster_at"], name: "index_characters_on_on_roster_at"
    t.index ["reviewed_by_id"], name: "index_characters_on_reviewed_by_id"
    t.index ["room_id"], name: "index_characters_on_room_id"
  end

  create_table "conversation_members", force: :cascade do |t|
    t.bigint "conversation_id", null: false
    t.bigint "account_id", null: false
    t.bigint "via_character_id"
    t.datetime "last_read_at"
    t.datetime "emailed_at"
    t.datetime "left_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_conversation_members_on_account_id"
    t.index ["conversation_id", "account_id"], name: "index_conversation_members_on_conversation_id_and_account_id", unique: true
    t.index ["conversation_id"], name: "index_conversation_members_on_conversation_id"
    t.index ["via_character_id"], name: "index_conversation_members_on_via_character_id"
  end

  create_table "conversations", force: :cascade do |t|
    t.string "subject", null: false
    t.datetime "last_message_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "exits", force: :cascade do |t|
    t.bigint "source_room_id", null: false
    t.bigint "destination_room_id", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "direction"
    t.string "number"
    t.string "kind", default: "street", null: false
    t.index ["destination_room_id"], name: "index_exits_on_destination_room_id"
    t.index ["source_room_id", "name"], name: "index_exits_on_source_room_id_and_name", unique: true
    t.index ["source_room_id", "number"], name: "index_exits_on_source_room_id_and_number", unique: true, where: "(number IS NOT NULL)"
    t.index ["source_room_id"], name: "index_exits_on_source_room_id"
  end

  create_table "forum_boards", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.integer "position", default: 0, null: false
    t.string "who_can_start", default: "everyone", null: false
    t.string "who_can_reply", default: "everyone", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "forum_posts", force: :cascade do |t|
    t.bigint "topic_id", null: false
    t.bigint "account_id"
    t.text "body", null: false
    t.datetime "edited_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_forum_posts_on_account_id"
    t.index ["topic_id", "created_at"], name: "index_forum_posts_on_topic_id_and_created_at"
    t.index ["topic_id"], name: "index_forum_posts_on_topic_id"
  end

  create_table "forum_topics", force: :cascade do |t|
    t.bigint "board_id", null: false
    t.bigint "account_id"
    t.string "title", null: false
    t.datetime "pinned_at"
    t.datetime "locked_at"
    t.datetime "last_posted_at", null: false
    t.integer "posts_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_forum_topics_on_account_id"
    t.index ["board_id", "last_posted_at"], name: "index_forum_topics_on_board_id_and_last_posted_at"
    t.index ["board_id"], name: "index_forum_topics_on_board_id"
  end

  create_table "gallery_images", force: :cascade do |t|
    t.bigint "character_id", null: false
    t.string "caption"
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["character_id"], name: "index_gallery_images_on_character_id"
  end

  create_table "game_settings", force: :cascade do |t|
    t.boolean "email_required", default: true, null: false
    t.boolean "approval_required", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "auto_skip", default: true, null: false
    t.integer "turn_minutes", default: 5, null: false
    t.integer "idle_days", default: 7, null: false
    t.integer "auto_finish_days", default: 30, null: false
    t.boolean "block_vpns", default: false, null: false
    t.boolean "guest_chat", default: true, null: false
    t.boolean "players_public", default: false, null: false
    t.datetime "ic_anchor_at"
    t.date "ic_anchor_date"
    t.decimal "ic_days_per_day", precision: 6, scale: 2, default: "1.0", null: false
    t.boolean "require_description", default: false, null: false
    t.boolean "require_icon", default: false, null: false
    t.boolean "soul_enabled", default: true, null: false
    t.integer "roster_idle_days", default: 90, null: false
    t.string "weather"
    t.boolean "inklings_enabled", default: true, null: false
    t.boolean "grimoire_enabled", default: false, null: false
    t.boolean "wiki_enabled", default: true, null: false
    t.jsonb "skin_colours", default: {}, null: false
    t.jsonb "skin_dark_colours", default: {}, null: false
    t.boolean "skin_dark_mode", default: true, null: false
    t.string "font_body"
    t.string "font_heading"
    t.text "custom_css"
    t.boolean "roster_claim", default: false, null: false
    t.boolean "roster_resubmit", default: false, null: false
    t.datetime "look_chosen_at"
    t.string "game_name"
    t.text "game_blurb"
    t.string "skin_base"
    t.boolean "compass_enabled", default: false, null: false
    t.string "profile_box", default: "top", null: false
    t.string "chapter_layout", default: "manuscript", null: false
    t.string "chapter_cast_portraits", default: "large", null: false
    t.string "chapter_passage_portraits", default: "small", null: false
    t.boolean "locked", default: false, null: false
    t.string "font_title"
  end

  create_table "grimoire_branches", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.bigint "soul_skill_id", null: false
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["soul_skill_id"], name: "index_grimoire_branches_on_soul_skill_id"
  end

  create_table "grimoire_learned_spells", force: :cascade do |t|
    t.bigint "character_id", null: false
    t.bigint "spell_id", null: false
    t.integer "xp_cost", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["character_id", "spell_id"], name: "index_grimoire_learned_spells_on_character_id_and_spell_id", unique: true
    t.index ["character_id"], name: "index_grimoire_learned_spells_on_character_id"
    t.index ["spell_id"], name: "index_grimoire_learned_spells_on_spell_id"
  end

  create_table "grimoire_proposals", force: :cascade do |t|
    t.bigint "character_id", null: false
    t.bigint "branch_id", null: false
    t.string "name", null: false
    t.text "description", null: false
    t.integer "minimum_rating", default: 1, null: false
    t.string "difficulty_name", default: "standard", null: false
    t.string "status", default: "pending", null: false
    t.string "staff_reason"
    t.bigint "reviewed_by_id"
    t.datetime "reviewed_at"
    t.bigint "spell_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["branch_id"], name: "index_grimoire_proposals_on_branch_id"
    t.index ["character_id"], name: "index_grimoire_proposals_on_character_id"
    t.index ["reviewed_by_id"], name: "index_grimoire_proposals_on_reviewed_by_id"
    t.index ["spell_id"], name: "index_grimoire_proposals_on_spell_id"
  end

  create_table "grimoire_spells", force: :cascade do |t|
    t.bigint "branch_id", null: false
    t.string "name", null: false
    t.text "description"
    t.integer "minimum_rating", default: 1, null: false
    t.string "difficulty_name", default: "standard", null: false
    t.boolean "active", default: true, null: false
    t.bigint "created_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["branch_id"], name: "index_grimoire_spells_on_branch_id"
    t.index ["created_by_id"], name: "index_grimoire_spells_on_created_by_id"
  end

  create_table "guest_visits", force: :cascade do |t|
    t.string "token", null: false
    t.bigint "room_id", null: false
    t.datetime "seen_at", null: false
    t.index ["room_id"], name: "index_guest_visits_on_room_id"
    t.index ["seen_at"], name: "index_guest_visits_on_seen_at"
    t.index ["token"], name: "index_guest_visits_on_token", unique: true
  end

  create_table "inkling_entries", force: :cascade do |t|
    t.bigint "inkling_id", null: false
    t.integer "sequence", null: false
    t.bigint "account_id"
    t.bigint "character_id"
    t.bigint "private_to_id"
    t.string "kind", default: "public", null: false
    t.text "body", null: false
    t.boolean "private", default: false, null: false
    t.bigint "soul_roll_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "scene_id"
    t.index ["account_id"], name: "index_inkling_entries_on_account_id"
    t.index ["character_id"], name: "index_inkling_entries_on_character_id"
    t.index ["inkling_id", "sequence"], name: "index_inkling_entries_on_inkling_id_and_sequence", unique: true
    t.index ["inkling_id"], name: "index_inkling_entries_on_inkling_id"
    t.index ["private_to_id"], name: "index_inkling_entries_on_private_to_id"
    t.index ["scene_id"], name: "index_inkling_entries_on_scene_id"
    t.index ["soul_roll_id"], name: "index_inkling_entries_on_soul_roll_id"
  end

  create_table "inkling_reads", force: :cascade do |t|
    t.bigint "inkling_id", null: false
    t.bigint "account_id", null: false
    t.integer "last_read_sequence", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_inkling_reads_on_account_id"
    t.index ["inkling_id", "account_id"], name: "index_inkling_reads_on_inkling_id_and_account_id", unique: true
    t.index ["inkling_id"], name: "index_inkling_reads_on_inkling_id"
  end

  create_table "inkling_scene_links", force: :cascade do |t|
    t.bigint "inkling_id", null: false
    t.bigint "scene_id", null: false
    t.bigint "linked_by_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["inkling_id", "scene_id"], name: "index_inkling_scene_links_on_inkling_id_and_scene_id", unique: true
    t.index ["inkling_id"], name: "index_inkling_scene_links_on_inkling_id"
    t.index ["linked_by_id"], name: "index_inkling_scene_links_on_linked_by_id"
    t.index ["scene_id"], name: "index_inkling_scene_links_on_scene_id"
  end

  create_table "inkling_shares", force: :cascade do |t|
    t.bigint "inkling_id", null: false
    t.bigint "character_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["character_id"], name: "index_inkling_shares_on_character_id"
    t.index ["inkling_id", "character_id"], name: "index_inkling_shares_on_inkling_id_and_character_id", unique: true
    t.index ["inkling_id"], name: "index_inkling_shares_on_inkling_id"
  end

  create_table "inklings", force: :cascade do |t|
    t.bigint "character_id", null: false
    t.bigint "creator_id", null: false
    t.string "kind", null: false
    t.string "title", null: false
    t.string "status", default: "open", null: false
    t.string "review_state", default: "draft", null: false
    t.datetime "submitted_at"
    t.datetime "staff_visible_at"
    t.integer "last_sequence", default: 0, null: false
    t.datetime "last_entry_at"
    t.string "tags", default: [], null: false, array: true
    t.integer "shared_group_ids", default: [], null: false, array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["character_id"], name: "index_inklings_on_character_id"
    t.index ["creator_id"], name: "index_inklings_on_creator_id"
    t.index ["review_state"], name: "index_inklings_on_review_state"
  end

  create_table "messages", force: :cascade do |t|
    t.bigint "conversation_id", null: false
    t.bigint "account_id"
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_messages_on_account_id"
    t.index ["conversation_id"], name: "index_messages_on_conversation_id"
  end

  create_table "name_changes", force: :cascade do |t|
    t.string "subject_type", null: false
    t.bigint "subject_id", null: false
    t.string "old_name", null: false
    t.string "new_name", null: false
    t.bigint "changed_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["changed_by_id"], name: "index_name_changes_on_changed_by_id"
    t.index ["created_at"], name: "index_name_changes_on_created_at"
    t.index ["subject_type", "subject_id"], name: "index_name_changes_on_subject_type_and_subject_id"
  end

  create_table "ooc_messages", force: :cascade do |t|
    t.bigint "account_id"
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "guest_name"
    t.inet "ip_address"
    t.datetime "edited_at"
    t.boolean "edited_by_staff", default: false, null: false
    t.datetime "deleted_at"
    t.bigint "removed_by_id"
    t.index ["account_id"], name: "index_ooc_messages_on_account_id"
    t.index ["removed_by_id"], name: "index_ooc_messages_on_removed_by_id"
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
    t.datetime "hidden_by_staff_at"
    t.string "npc_name"
    t.index ["character_id"], name: "index_poses_on_character_id"
    t.index ["scene_id", "sequence"], name: "index_poses_on_scene_id_and_sequence", unique: true
    t.index ["scene_id"], name: "index_poses_on_scene_id"
  end

  create_table "profile_fields", force: :cascade do |t|
    t.string "name", null: false
    t.string "section", default: "demographics", null: false
    t.string "field_type", default: "text", null: false
    t.boolean "public", default: true, null: false
    t.boolean "required", default: false, null: false
    t.integer "position", default: 0, null: false
    t.string "hint"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "on_passages", default: false, null: false
    t.boolean "ask_on_roster", default: false, null: false
    t.string "inkling_kind"
    t.boolean "player_can_edit", default: true, null: false
    t.boolean "age_on_passages", default: false, null: false
  end

  create_table "profile_values", force: :cascade do |t|
    t.bigint "character_id", null: false
    t.bigint "profile_field_id", null: false
    t.text "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["character_id", "profile_field_id"], name: "index_profile_values_on_character_id_and_profile_field_id", unique: true
    t.index ["character_id"], name: "index_profile_values_on_character_id"
    t.index ["profile_field_id"], name: "index_profile_values_on_profile_field_id"
  end

  create_table "relationships", force: :cascade do |t|
    t.bigint "character_id", null: false
    t.bigint "other_character_id"
    t.string "other_name"
    t.string "kind", default: "friend", null: false
    t.text "note"
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["character_id"], name: "index_relationships_on_character_id"
    t.index ["other_character_id"], name: "index_relationships_on_other_character_id"
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

  create_table "reports", force: :cascade do |t|
    t.bigint "scene_id", null: false
    t.bigint "pose_id"
    t.bigint "account_id", null: false
    t.text "reason", null: false
    t.datetime "resolved_at"
    t.bigint "resolved_by_id"
    t.text "resolution"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_reports_on_account_id"
    t.index ["pose_id"], name: "index_reports_on_pose_id"
    t.index ["resolved_by_id"], name: "index_reports_on_resolved_by_id"
    t.index ["scene_id"], name: "index_reports_on_scene_id"
  end

  create_table "rooms", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.boolean "starting", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "area_id", null: false
    t.string "summary"
    t.string "kind", default: "plain", null: false
    t.index ["area_id"], name: "index_rooms_on_area_id"
  end

  create_table "roster_applications", force: :cascade do |t|
    t.bigint "character_id", null: false
    t.bigint "account_id", null: false
    t.text "note", null: false
    t.string "status", default: "pending", null: false
    t.string "staff_reason"
    t.bigint "reviewed_by_id"
    t.datetime "reviewed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "answers", default: {}, null: false
    t.index ["account_id"], name: "index_roster_applications_on_account_id"
    t.index ["character_id"], name: "index_roster_applications_on_character_id"
    t.index ["reviewed_by_id"], name: "index_roster_applications_on_reviewed_by_id"
  end

  create_table "saved_places", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.bigint "room_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "room_id"], name: "index_saved_places_on_account_id_and_room_id", unique: true
    t.index ["account_id"], name: "index_saved_places_on_account_id"
    t.index ["room_id"], name: "index_saved_places_on_room_id"
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

  create_table "scene_labels", force: :cascade do |t|
    t.string "name", null: false
    t.string "description"
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "scene_participants", force: :cascade do |t|
    t.bigint "scene_id", null: false
    t.bigint "character_id", null: false
    t.string "role", default: "player", null: false
    t.integer "position", null: false
    t.integer "last_read_sequence", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "public_consent_at"
    t.integer "notified_up_to", default: 0, null: false
    t.boolean "tab_closed", default: false, null: false
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
    t.datetime "finished_at"
    t.bigint "finished_by_id"
    t.datetime "locked_at"
    t.datetime "made_public_at"
    t.datetime "paused_at"
    t.string "pause_note"
    t.string "subtitle"
    t.integer "label_ids", default: [], null: false, array: true
    t.date "ic_date"
    t.string "ic_time"
    t.integer "number", null: false
    t.index ["current_turn_participant_id"], name: "index_scenes_on_current_turn_participant_id"
    t.index ["finished_at"], name: "index_scenes_on_finished_at"
    t.index ["finished_by_id"], name: "index_scenes_on_finished_by_id"
    t.index ["last_pose_at"], name: "index_scenes_on_last_pose_at"
    t.index ["number"], name: "index_scenes_on_number", unique: true
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

  create_table "skin_fonts", force: :cascade do |t|
    t.bigint "game_setting_id", null: false
    t.string "family", null: false
    t.integer "weight", default: 400, null: false
    t.string "style", default: "normal", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["game_setting_id", "family", "weight", "style"], name: "index_skin_fonts_on_face", unique: true
    t.index ["game_setting_id"], name: "index_skin_fonts_on_game_setting_id"
  end

  create_table "soul_aspects", force: :cascade do |t|
    t.string "key", null: false
    t.string "name", null: false
    t.string "description"
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_soul_aspects_on_key", unique: true
  end

  create_table "soul_audit_entries", force: :cascade do |t|
    t.bigint "character_id"
    t.bigint "actor_id"
    t.string "action", null: false
    t.string "summary", null: false
    t.string "reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id"], name: "index_soul_audit_entries_on_actor_id"
    t.index ["character_id"], name: "index_soul_audit_entries_on_character_id"
  end

  create_table "soul_award_suggestions", force: :cascade do |t|
    t.bigint "character_id", null: false
    t.bigint "scene_id", null: false
    t.bigint "suggested_by_id", null: false
    t.integer "amount", null: false
    t.text "reason", null: false
    t.string "status", default: "pending", null: false
    t.string "staff_reason"
    t.bigint "reviewed_by_id"
    t.datetime "reviewed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["character_id"], name: "index_soul_award_suggestions_on_character_id"
    t.index ["reviewed_by_id"], name: "index_soul_award_suggestions_on_reviewed_by_id"
    t.index ["scene_id"], name: "index_soul_award_suggestions_on_scene_id"
    t.index ["suggested_by_id"], name: "index_soul_award_suggestions_on_suggested_by_id"
  end

  create_table "soul_bnb_requests", force: :cascade do |t|
    t.bigint "character_id", null: false
    t.bigint "soul_bnb_id", null: false
    t.string "level", default: "minor", null: false
    t.integer "skill_ids", default: [], null: false, array: true
    t.text "explanation"
    t.string "status", default: "pending", null: false
    t.string "staff_reason"
    t.bigint "reviewed_by_id"
    t.datetime "reviewed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["character_id"], name: "index_soul_bnb_requests_on_character_id"
    t.index ["reviewed_by_id"], name: "index_soul_bnb_requests_on_reviewed_by_id"
    t.index ["soul_bnb_id"], name: "index_soul_bnb_requests_on_soul_bnb_id"
  end

  create_table "soul_bnbs", force: :cascade do |t|
    t.string "kind", null: false
    t.string "name", null: false
    t.text "description"
    t.integer "skill_ids", default: [], null: false, array: true
    t.boolean "starting", default: true, null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "soul_character_bnbs", force: :cascade do |t|
    t.bigint "character_id", null: false
    t.bigint "soul_bnb_id", null: false
    t.string "level", default: "minor", null: false
    t.integer "skill_ids", default: [], null: false, array: true
    t.text "explanation"
    t.string "source", null: false
    t.datetime "resolved_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["character_id"], name: "index_soul_character_bnbs_on_character_id"
    t.index ["soul_bnb_id"], name: "index_soul_character_bnbs_on_soul_bnb_id"
  end

  create_table "soul_culminations", force: :cascade do |t|
    t.bigint "character_id", null: false
    t.string "title", null: false
    t.text "description"
    t.string "status", default: "proposed", null: false
    t.string "staff_reason"
    t.bigint "reviewed_by_id"
    t.datetime "reviewed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["character_id"], name: "index_soul_culminations_on_character_id"
    t.index ["reviewed_by_id"], name: "index_soul_culminations_on_reviewed_by_id"
  end

  create_table "soul_history_entries", force: :cascade do |t|
    t.bigint "character_id", null: false
    t.string "event", null: false
    t.string "narrative", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["character_id"], name: "index_soul_history_entries_on_character_id"
  end

  create_table "soul_pending_rolls", force: :cascade do |t|
    t.bigint "character_id", null: false
    t.bigint "scene_id", null: false
    t.bigint "soul_skill_id", null: false
    t.string "difficulty_name", null: false
    t.string "status", default: "waiting", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "called", default: false, null: false
    t.integer "mandatory_bnb_ids", default: [], null: false, array: true
    t.integer "optional_bnb_ids", default: [], null: false, array: true
    t.bigint "judge_id"
    t.index ["character_id"], name: "index_soul_pending_rolls_on_character_id"
    t.index ["scene_id"], name: "index_soul_pending_rolls_on_scene_id"
    t.index ["soul_skill_id"], name: "index_soul_pending_rolls_on_soul_skill_id"
  end

  create_table "soul_rating_guides", force: :cascade do |t|
    t.integer "low", null: false
    t.integer "high", null: false
    t.string "name", null: false
    t.text "description"
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "soul_ratings", force: :cascade do |t|
    t.bigint "character_id", null: false
    t.string "trait_type", null: false
    t.bigint "trait_id", null: false
    t.integer "rating", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["character_id", "trait_type", "trait_id"], name: "index_soul_ratings_on_character_id_and_trait_type_and_trait_id", unique: true
    t.index ["character_id"], name: "index_soul_ratings_on_character_id"
    t.index ["trait_type", "trait_id"], name: "index_soul_ratings_on_trait"
  end

  create_table "soul_rolls", force: :cascade do |t|
    t.bigint "character_id", null: false
    t.bigint "scene_id"
    t.bigint "pose_id"
    t.bigint "soul_skill_id"
    t.string "skill_name", null: false
    t.string "difficulty_name", null: false
    t.integer "difficulty", null: false
    t.integer "skill_rating", null: false
    t.integer "aspect_bonus", null: false
    t.jsonb "dice", default: {}, null: false
    t.integer "result", null: false
    t.string "degree", null: false
    t.float "probability"
    t.boolean "extraordinary", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "net_modifier", default: 0, null: false
    t.jsonb "applied", default: [], null: false
    t.bigint "storyteller_id"
    t.index ["character_id"], name: "index_soul_rolls_on_character_id"
    t.index ["pose_id"], name: "index_soul_rolls_on_pose_id"
    t.index ["scene_id"], name: "index_soul_rolls_on_scene_id"
    t.index ["soul_skill_id"], name: "index_soul_rolls_on_soul_skill_id"
    t.index ["storyteller_id"], name: "index_soul_rolls_on_storyteller_id"
  end

  create_table "soul_skills", force: :cascade do |t|
    t.bigint "soul_aspect_id", null: false
    t.string "key", null: false
    t.string "name", null: false
    t.string "description"
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_soul_skills_on_key", unique: true
    t.index ["soul_aspect_id"], name: "index_soul_skills_on_soul_aspect_id"
  end

  create_table "soul_xp_entries", force: :cascade do |t|
    t.bigint "character_id", null: false
    t.string "kind", null: false
    t.string "source"
    t.integer "amount", null: false
    t.integer "catchup_amount", default: 0, null: false
    t.string "note"
    t.string "idempotency_key"
    t.bigint "actor_id"
    t.string "trait_type"
    t.bigint "trait_id"
    t.integer "new_rating"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id"], name: "index_soul_xp_entries_on_actor_id"
    t.index ["character_id"], name: "index_soul_xp_entries_on_character_id"
    t.index ["idempotency_key"], name: "index_soul_xp_entries_on_idempotency_key", unique: true
    t.index ["trait_type", "trait_id"], name: "index_soul_xp_entries_on_trait"
  end

  create_table "vpn_ranges", force: :cascade do |t|
    t.cidr "range", null: false
    t.index ["range"], name: "index_vpn_ranges_on_range", opclass: :inet_ops, using: :gist
  end

  create_table "well_updates", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.string "version", null: false
    t.string "request_id", null: false
    t.string "status", default: "requested", null: false
    t.string "conclusion"
    t.bigint "run_id"
    t.string "run_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "well_id"
    t.boolean "first_time", default: false, null: false
    t.index ["account_id"], name: "index_well_updates_on_account_id"
    t.index ["request_id"], name: "index_well_updates_on_request_id"
    t.index ["run_id"], name: "index_well_updates_on_run_id"
    t.index ["well_id"], name: "index_well_updates_on_well_id"
  end

  create_table "wells", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.string "domain", null: false
    t.string "setup_code", null: false
    t.string "status", default: "starting", null: false
    t.string "version"
    t.bigint "account_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "copy_founder", default: false, null: false
    t.datetime "founder_claimed_at"
    t.boolean "import_world", default: false, null: false
    t.index ["account_id"], name: "index_wells_on_account_id"
    t.index ["domain"], name: "index_wells_on_domain", unique: true
    t.index ["slug"], name: "index_wells_on_slug", unique: true
  end

  create_table "wiki_pages", force: :cascade do |t|
    t.string "title", null: false
    t.string "slug", null: false
    t.text "body", default: "", null: false
    t.string "tags", default: [], null: false, array: true
    t.datetime "locked_at"
    t.integer "menu_position"
    t.bigint "updated_by_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "old_slugs", default: [], null: false, array: true
    t.index ["old_slugs"], name: "index_wiki_pages_on_old_slugs", using: :gin
    t.index ["slug"], name: "index_wiki_pages_on_slug", unique: true
    t.index ["tags"], name: "index_wiki_pages_on_tags", using: :gin
    t.index ["updated_by_id"], name: "index_wiki_pages_on_updated_by_id"
  end

  create_table "wiki_revisions", force: :cascade do |t|
    t.bigint "page_id", null: false
    t.bigint "account_id"
    t.string "title", null: false
    t.text "body", default: "", null: false
    t.string "summary"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id"], name: "index_wiki_revisions_on_account_id"
    t.index ["page_id"], name: "index_wiki_revisions_on_page_id"
  end

  add_foreign_key "account_warnings", "accounts"
  add_foreign_key "account_warnings", "accounts", column: "staff_id"
  add_foreign_key "account_warnings", "reports"
  add_foreign_key "accounts", "characters", column: "active_character_id", on_delete: :nullify
  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "alerts", "accounts", on_delete: :cascade
  add_foreign_key "alerts", "characters", on_delete: :cascade
  add_foreign_key "alerts", "inklings", on_delete: :cascade
  add_foreign_key "alerts", "poses", on_delete: :nullify
  add_foreign_key "alerts", "scenes", on_delete: :cascade
  add_foreign_key "areas", "areas", column: "parent_id"
  add_foreign_key "areas", "rooms", column: "entrance_room_id", on_delete: :nullify
  add_foreign_key "bans", "accounts"
  add_foreign_key "bans", "accounts", column: "banned_by_id"
  add_foreign_key "characters", "accounts"
  add_foreign_key "characters", "accounts", column: "reviewed_by_id"
  add_foreign_key "characters", "character_groups", on_delete: :nullify
  add_foreign_key "characters", "rooms"
  add_foreign_key "conversation_members", "accounts"
  add_foreign_key "conversation_members", "characters", column: "via_character_id"
  add_foreign_key "conversation_members", "conversations"
  add_foreign_key "exits", "rooms", column: "destination_room_id"
  add_foreign_key "exits", "rooms", column: "source_room_id"
  add_foreign_key "forum_posts", "accounts", on_delete: :nullify
  add_foreign_key "forum_posts", "forum_topics", column: "topic_id", on_delete: :cascade
  add_foreign_key "forum_topics", "accounts", on_delete: :nullify
  add_foreign_key "forum_topics", "forum_boards", column: "board_id", on_delete: :cascade
  add_foreign_key "gallery_images", "characters"
  add_foreign_key "grimoire_branches", "soul_skills"
  add_foreign_key "grimoire_learned_spells", "characters"
  add_foreign_key "grimoire_learned_spells", "grimoire_spells", column: "spell_id"
  add_foreign_key "grimoire_proposals", "accounts", column: "reviewed_by_id"
  add_foreign_key "grimoire_proposals", "characters"
  add_foreign_key "grimoire_proposals", "grimoire_branches", column: "branch_id"
  add_foreign_key "grimoire_proposals", "grimoire_spells", column: "spell_id", on_delete: :nullify
  add_foreign_key "grimoire_spells", "accounts", column: "created_by_id", on_delete: :nullify
  add_foreign_key "grimoire_spells", "grimoire_branches", column: "branch_id"
  add_foreign_key "guest_visits", "rooms", on_delete: :cascade
  add_foreign_key "inkling_entries", "accounts", on_delete: :nullify
  add_foreign_key "inkling_entries", "characters", column: "private_to_id", on_delete: :nullify
  add_foreign_key "inkling_entries", "characters", on_delete: :nullify
  add_foreign_key "inkling_entries", "inklings", on_delete: :cascade
  add_foreign_key "inkling_entries", "scenes", on_delete: :nullify
  add_foreign_key "inkling_entries", "soul_rolls", on_delete: :nullify
  add_foreign_key "inkling_reads", "accounts", on_delete: :cascade
  add_foreign_key "inkling_reads", "inklings", on_delete: :cascade
  add_foreign_key "inkling_scene_links", "accounts", column: "linked_by_id"
  add_foreign_key "inkling_scene_links", "inklings"
  add_foreign_key "inkling_scene_links", "scenes"
  add_foreign_key "inkling_shares", "characters", on_delete: :cascade
  add_foreign_key "inkling_shares", "inklings", on_delete: :cascade
  add_foreign_key "inklings", "accounts", column: "creator_id"
  add_foreign_key "inklings", "characters"
  add_foreign_key "messages", "accounts"
  add_foreign_key "messages", "conversations"
  add_foreign_key "name_changes", "accounts", column: "changed_by_id", on_delete: :nullify
  add_foreign_key "ooc_messages", "accounts"
  add_foreign_key "ooc_messages", "accounts", column: "removed_by_id", on_delete: :nullify
  add_foreign_key "poses", "characters"
  add_foreign_key "poses", "scenes"
  add_foreign_key "profile_values", "characters"
  add_foreign_key "profile_values", "profile_fields"
  add_foreign_key "relationships", "characters"
  add_foreign_key "relationships", "characters", column: "other_character_id"
  add_foreign_key "remembered_characters", "accounts"
  add_foreign_key "remembered_characters", "characters", on_delete: :cascade
  add_foreign_key "reports", "accounts"
  add_foreign_key "reports", "accounts", column: "resolved_by_id"
  add_foreign_key "reports", "poses"
  add_foreign_key "reports", "scenes"
  add_foreign_key "rooms", "areas"
  add_foreign_key "roster_applications", "accounts"
  add_foreign_key "roster_applications", "accounts", column: "reviewed_by_id"
  add_foreign_key "roster_applications", "characters"
  add_foreign_key "saved_places", "accounts"
  add_foreign_key "saved_places", "rooms"
  add_foreign_key "scene_invitations", "characters"
  add_foreign_key "scene_invitations", "scenes"
  add_foreign_key "scene_participants", "characters"
  add_foreign_key "scene_participants", "scenes"
  add_foreign_key "scenes", "characters", column: "finished_by_id", on_delete: :nullify
  add_foreign_key "scenes", "rooms"
  add_foreign_key "scenes", "scene_participants", column: "current_turn_participant_id", on_delete: :nullify
  add_foreign_key "sessions", "accounts"
  add_foreign_key "skin_fonts", "game_settings"
  add_foreign_key "soul_audit_entries", "accounts", column: "actor_id"
  add_foreign_key "soul_audit_entries", "characters", on_delete: :nullify
  add_foreign_key "soul_award_suggestions", "accounts", column: "reviewed_by_id"
  add_foreign_key "soul_award_suggestions", "accounts", column: "suggested_by_id"
  add_foreign_key "soul_award_suggestions", "characters"
  add_foreign_key "soul_award_suggestions", "scenes"
  add_foreign_key "soul_bnb_requests", "accounts", column: "reviewed_by_id"
  add_foreign_key "soul_bnb_requests", "characters"
  add_foreign_key "soul_bnb_requests", "soul_bnbs"
  add_foreign_key "soul_character_bnbs", "characters"
  add_foreign_key "soul_character_bnbs", "soul_bnbs"
  add_foreign_key "soul_culminations", "accounts", column: "reviewed_by_id"
  add_foreign_key "soul_culminations", "characters"
  add_foreign_key "soul_history_entries", "characters"
  add_foreign_key "soul_pending_rolls", "characters"
  add_foreign_key "soul_pending_rolls", "scenes"
  add_foreign_key "soul_pending_rolls", "soul_skills"
  add_foreign_key "soul_ratings", "characters"
  add_foreign_key "soul_rolls", "characters"
  add_foreign_key "soul_rolls", "characters", column: "storyteller_id", on_delete: :nullify
  add_foreign_key "soul_rolls", "poses"
  add_foreign_key "soul_rolls", "scenes"
  add_foreign_key "soul_rolls", "soul_skills", on_delete: :nullify
  add_foreign_key "soul_skills", "soul_aspects"
  add_foreign_key "soul_xp_entries", "accounts", column: "actor_id"
  add_foreign_key "soul_xp_entries", "characters"
  add_foreign_key "well_updates", "accounts"
  add_foreign_key "well_updates", "wells"
  add_foreign_key "wells", "accounts"
  add_foreign_key "wiki_pages", "accounts", column: "updated_by_id", on_delete: :nullify
  add_foreign_key "wiki_revisions", "accounts", on_delete: :nullify
  add_foreign_key "wiki_revisions", "wiki_pages", column: "page_id", on_delete: :cascade
end
