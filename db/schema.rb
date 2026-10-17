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

ActiveRecord::Schema[8.1].define(version: 2026_10_18_143300) do
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
    t.boolean "awaiting_approval", default: false, null: false
    t.date "away_until"
    t.string "away_note"
    t.datetime "lfrp_nudged_at"
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
    t.bigint "faction_id"
    t.string "note"
    t.bigint "event_id"
    t.index ["account_id", "read_at"], name: "index_alerts_on_account_id_and_read_at"
    t.index ["account_id"], name: "index_alerts_on_account_id"
    t.index ["character_id"], name: "index_alerts_on_character_id"
    t.index ["event_id"], name: "index_alerts_on_event_id"
    t.index ["faction_id"], name: "index_alerts_on_faction_id"
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
    t.boolean "needs_players", default: false, null: false
    t.string "wanted_note"
    t.text "ranks"
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
    t.date "deceased_on"
    t.string "deceased_note"
    t.datetime "lfrp_at"
    t.string "lfrp_i_am"
    t.string "lfrp_looking_for"
    t.string "group_rank"
    t.boolean "group_leader", default: false, null: false
    t.index "lower((name)::text)", name: "index_characters_on_lower_name", unique: true
    t.index ["account_id"], name: "index_characters_on_account_id"
    t.index ["character_group_id"], name: "index_characters_on_character_group_id"
    t.index ["deceased_on"], name: "index_characters_on_deceased_on"
    t.index ["lfrp_at"], name: "index_characters_on_lfrp_at"
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
    t.boolean "live_open", default: false, null: false
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

  create_table "crafting_catalogue_items", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.integer "price", default: 0, null: false
    t.integer "feature_ids", default: [], null: false, array: true
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "crafting_features", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.string "level", default: "minor", null: false
    t.integer "skill_ids", default: [], null: false, array: true
    t.integer "item_type_ids", default: [], null: false, array: true
    t.string "status", default: "approved", null: false
    t.bigint "proposed_by_id"
    t.string "decline_reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["proposed_by_id"], name: "index_crafting_features_on_proposed_by_id"
  end

  create_table "crafting_item_events", force: :cascade do |t|
    t.bigint "item_id"
    t.string "item_name", null: false
    t.integer "quantity", default: 1, null: false
    t.bigint "character_id"
    t.bigint "other_character_id"
    t.string "kind", null: false
    t.string "note"
    t.bigint "actor_id"
    t.datetime "created_at", null: false
    t.index ["actor_id"], name: "index_crafting_item_events_on_actor_id"
    t.index ["character_id"], name: "index_crafting_item_events_on_character_id"
    t.index ["item_id"], name: "index_crafting_item_events_on_item_id"
    t.index ["other_character_id"], name: "index_crafting_item_events_on_other_character_id"
  end

  create_table "crafting_item_types", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.integer "base_cost", default: 0, null: false
    t.bigint "soul_skill_id"
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["soul_skill_id"], name: "index_crafting_item_types_on_soul_skill_id"
  end

  create_table "crafting_items", force: :cascade do |t|
    t.bigint "character_id", null: false
    t.string "name", null: false
    t.text "description"
    t.integer "quantity", default: 1, null: false
    t.bigint "catalogue_item_id"
    t.bigint "item_type_id"
    t.integer "feature_ids", default: [], null: false, array: true
    t.bigint "maker_id"
    t.string "maker_name"
    t.datetime "made_at"
    t.boolean "masterwork", default: false, null: false
    t.string "flaw_name"
    t.integer "flaw_skill_ids", default: [], null: false, array: true
    t.integer "price"
    t.datetime "listed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["catalogue_item_id"], name: "index_crafting_items_on_catalogue_item_id"
    t.index ["character_id"], name: "index_crafting_items_on_character_id"
    t.index ["item_type_id"], name: "index_crafting_items_on_item_type_id"
    t.index ["listed_at"], name: "index_crafting_items_on_listed_at"
    t.index ["maker_id"], name: "index_crafting_items_on_maker_id"
  end

  create_table "crafting_shop_listings", force: :cascade do |t|
    t.bigint "room_id", null: false
    t.bigint "catalogue_item_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["catalogue_item_id"], name: "index_crafting_shop_listings_on_catalogue_item_id"
    t.index ["room_id", "catalogue_item_id"], name: "index_crafting_shop_listings_on_room_id_and_catalogue_item_id", unique: true
    t.index ["room_id"], name: "index_crafting_shop_listings_on_room_id"
  end

  create_table "crafting_trade_items", force: :cascade do |t|
    t.bigint "trade_id", null: false
    t.bigint "item_id", null: false
    t.integer "quantity", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["item_id"], name: "index_crafting_trade_items_on_item_id"
    t.index ["trade_id", "item_id"], name: "index_crafting_trade_items_on_trade_id_and_item_id", unique: true
    t.index ["trade_id"], name: "index_crafting_trade_items_on_trade_id"
  end

  create_table "crafting_trades", force: :cascade do |t|
    t.bigint "from_character_id", null: false
    t.bigint "to_character_id", null: false
    t.integer "from_money", default: 0, null: false
    t.integer "to_money", default: 0, null: false
    t.boolean "from_agreed", default: false, null: false
    t.boolean "to_agreed", default: false, null: false
    t.string "status", default: "open", null: false
    t.bigint "scene_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["from_character_id"], name: "index_crafting_trades_on_from_character_id"
    t.index ["scene_id"], name: "index_crafting_trades_on_scene_id"
    t.index ["to_character_id"], name: "index_crafting_trades_on_to_character_id"
  end

  create_table "domains", force: :cascade do |t|
    t.string "name", null: false
    t.string "rank"
    t.text "description"
    t.bigint "liege_id"
    t.bigint "holder_character_id"
    t.bigint "holder_faction_id"
    t.bigint "area_id"
    t.integer "people", default: 0, null: false
    t.integer "yield_per_head", default: 0, null: false
    t.integer "tax_percent", default: 0, null: false
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "lower((name)::text)", name: "index_domains_on_lower_name", unique: true
    t.index ["area_id"], name: "index_domains_on_area_id"
    t.index ["holder_character_id"], name: "index_domains_on_holder_character_id"
    t.index ["holder_faction_id"], name: "index_domains_on_holder_faction_id"
    t.index ["liege_id"], name: "index_domains_on_liege_id"
  end

  create_table "economy_accounts", force: :cascade do |t|
    t.string "owner_type", null: false
    t.bigint "owner_id", null: false
    t.integer "balance", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["owner_type", "owner_id"], name: "index_economy_accounts_on_owner", unique: true
  end

  create_table "economy_allowance_changes", force: :cascade do |t|
    t.bigint "soul_bnb_id", null: false
    t.integer "amount", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["soul_bnb_id"], name: "index_economy_allowance_changes_on_soul_bnb_id", unique: true
  end

  create_table "economy_entries", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.bigint "counterparty_id"
    t.integer "amount", null: false
    t.integer "balance_after", null: false
    t.string "kind", null: false
    t.string "note"
    t.bigint "actor_id"
    t.bigint "actor_character_id"
    t.bigint "schedule_id"
    t.string "key"
    t.datetime "created_at", null: false
    t.index ["account_id", "created_at"], name: "index_economy_entries_on_account_id_and_created_at"
    t.index ["account_id"], name: "index_economy_entries_on_account_id"
    t.index ["actor_character_id"], name: "index_economy_entries_on_actor_character_id"
    t.index ["actor_id"], name: "index_economy_entries_on_actor_id"
    t.index ["counterparty_id"], name: "index_economy_entries_on_counterparty_id"
    t.index ["key"], name: "index_economy_entries_on_key", unique: true, where: "(key IS NOT NULL)"
    t.index ["schedule_id"], name: "index_economy_entries_on_schedule_id"
  end

  create_table "economy_schedules", force: :cascade do |t|
    t.bigint "from_account_id"
    t.bigint "to_account_id", null: false
    t.integer "amount", null: false
    t.string "interval", default: "week", null: false
    t.date "next_due_on", null: false
    t.date "ends_on"
    t.string "note"
    t.bigint "created_by_id"
    t.bigint "created_by_character_id"
    t.datetime "stopped_at"
    t.string "stopped_reason"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_character_id"], name: "index_economy_schedules_on_created_by_character_id"
    t.index ["created_by_id"], name: "index_economy_schedules_on_created_by_id"
    t.index ["from_account_id"], name: "index_economy_schedules_on_from_account_id"
    t.index ["to_account_id"], name: "index_economy_schedules_on_to_account_id"
  end

  create_table "event_signups", force: :cascade do |t|
    t.bigint "event_id", null: false
    t.bigint "character_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["character_id"], name: "index_event_signups_on_character_id"
    t.index ["event_id", "character_id"], name: "index_event_signups_on_event_id_and_character_id", unique: true
    t.index ["event_id"], name: "index_event_signups_on_event_id"
  end

  create_table "events", force: :cascade do |t|
    t.string "title", null: false
    t.text "description"
    t.bigint "room_id", null: false
    t.datetime "starts_at", null: false
    t.bigint "host_id"
    t.bigint "created_by_id"
    t.bigint "scene_id"
    t.datetime "opened_at"
    t.datetime "cancelled_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_by_id"], name: "index_events_on_created_by_id"
    t.index ["host_id"], name: "index_events_on_host_id"
    t.index ["room_id"], name: "index_events_on_room_id"
    t.index ["scene_id"], name: "index_events_on_scene_id"
    t.index ["starts_at"], name: "index_events_on_starts_at"
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

  create_table "faction_memberships", force: :cascade do |t|
    t.bigint "faction_id", null: false
    t.bigint "character_id", null: false
    t.string "title"
    t.boolean "head", default: false, null: false
    t.boolean "secret", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "bank_manager", default: false, null: false
    t.index ["character_id"], name: "index_faction_memberships_on_character_id"
    t.index ["faction_id", "character_id"], name: "index_faction_memberships_on_faction_id_and_character_id", unique: true
    t.index ["faction_id"], name: "index_faction_memberships_on_faction_id"
  end

  create_table "faction_requests", force: :cascade do |t|
    t.bigint "faction_id", null: false
    t.bigint "character_id", null: false
    t.string "note"
    t.string "status", default: "pending", null: false
    t.bigint "decided_by_id"
    t.datetime "decided_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["character_id"], name: "index_faction_requests_on_character_id"
    t.index ["decided_by_id"], name: "index_faction_requests_on_decided_by_id"
    t.index ["faction_id", "character_id"], name: "index_faction_requests_one_pending", unique: true, where: "((status)::text = 'pending'::text)"
    t.index ["faction_id"], name: "index_faction_requests_on_faction_id"
  end

  create_table "factions", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.string "npc_heads"
    t.boolean "secret", default: false, null: false
    t.boolean "pick_on_application", default: true, null: false
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "income_tax_percent", default: 0, null: false
    t.integer "dues_amount", default: 0, null: false
    t.string "dues_interval", default: "month", null: false
    t.date "dues_next_on"
    t.index "lower((name)::text)", name: "index_factions_on_lower_name", unique: true
  end

  create_table "forum_boards", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.integer "position", default: 0, null: false
    t.string "who_can_start", default: "everyone", null: false
    t.string "who_can_reply", default: "everyone", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "in_character", default: false, null: false
    t.bigint "character_group_id"
    t.index ["character_group_id"], name: "index_forum_boards_on_character_group_id", unique: true
  end

  create_table "forum_posts", force: :cascade do |t|
    t.bigint "topic_id", null: false
    t.bigint "account_id"
    t.text "body", null: false
    t.datetime "edited_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "character_id"
    t.index ["account_id"], name: "index_forum_posts_on_account_id"
    t.index ["character_id"], name: "index_forum_posts_on_character_id"
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
    t.bigint "character_id"
    t.index ["account_id"], name: "index_forum_topics_on_account_id"
    t.index ["board_id", "last_posted_at"], name: "index_forum_topics_on_board_id_and_last_posted_at"
    t.index ["board_id"], name: "index_forum_topics_on_board_id"
    t.index ["character_id"], name: "index_forum_topics_on_character_id"
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
    t.boolean "factions_enabled", default: false, null: false
    t.boolean "economy_enabled", default: false, null: false
    t.boolean "economy_taxes_enabled", default: false, null: false
    t.string "currency_one", default: "crown", null: false
    t.string "currency_other", default: "crowns", null: false
    t.string "currency_symbol"
    t.integer "economy_starting_amount", default: 0, null: false
    t.integer "economy_allowance", default: 0, null: false
    t.integer "economy_tax_max_percent", default: 25, null: false
    t.integer "economy_dues_max", default: 0, null: false
    t.string "chapter_tabs_side", default: "top", null: false
    t.boolean "domains_enabled", default: false, null: false
    t.integer "domain_tax_max_percent", default: 50, null: false
    t.boolean "private_game", default: false, null: false
    t.boolean "player_approval_required", default: false, null: false
    t.boolean "crafting_enabled", default: false, null: false
    t.integer "crafting_max_features", default: 3, null: false
    t.string "crafting_highest_level", default: "major", null: false
    t.integer "crafting_minor_cost", default: 200, null: false
    t.integer "crafting_major_cost", default: 600, null: false
    t.integer "crafting_legendary_cost", default: 2000, null: false
    t.boolean "character_spotlight", default: true, null: false
    t.boolean "mini_map_enabled", default: true, null: false
    t.boolean "weather_auto", default: false, null: false
    t.boolean "weather_southern", default: false, null: false
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
    t.integer "shared_faction_ids", default: [], null: false, array: true
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

  create_table "npcs", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.text "notes"
    t.jsonb "soul_ratings", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "lower((name)::text)", name: "index_npcs_on_lower_name", unique: true
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
    t.bigint "to_character_ids", default: [], null: false, array: true
    t.text "overheard_body"
    t.string "letter_style"
    t.string "letter_to"
    t.bigint "npc_id"
    t.index ["character_id"], name: "index_poses_on_character_id"
    t.index ["npc_id"], name: "index_poses_on_npc_id"
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

  create_table "scene_bounties", force: :cascade do |t|
    t.bigint "account_id", null: false
    t.date "week_of", null: false
    t.bigint "character_ids", default: [], null: false, array: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["account_id", "week_of"], name: "index_scene_bounties_on_account_id_and_week_of", unique: true
    t.index ["account_id"], name: "index_scene_bounties_on_account_id"
  end

  create_table "scene_ideas", force: :cascade do |t|
    t.string "title", null: false
    t.string "subtitle"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.datetime "storyteller_wanted_at"
    t.datetime "ruling_wanted_at"
    t.string "ruling_note"
    t.text "summary"
    t.bigint "summary_by_id"
    t.datetime "summary_at"
    t.string "speed"
    t.datetime "world_event_at"
    t.string "world_event_note"
    t.bigint "world_event_by_id"
    t.index ["current_turn_participant_id"], name: "index_scenes_on_current_turn_participant_id"
    t.index ["finished_at"], name: "index_scenes_on_finished_at"
    t.index ["finished_by_id"], name: "index_scenes_on_finished_by_id"
    t.index ["last_pose_at"], name: "index_scenes_on_last_pose_at"
    t.index ["number"], name: "index_scenes_on_number", unique: true
    t.index ["room_id"], name: "index_scenes_on_room_id"
    t.index ["ruling_wanted_at"], name: "index_scenes_on_ruling_wanted_at"
    t.index ["storyteller_wanted_at"], name: "index_scenes_on_storyteller_wanted_at"
    t.index ["summary_by_id"], name: "index_scenes_on_summary_by_id"
    t.index ["world_event_at"], name: "index_scenes_on_world_event_at"
    t.index ["world_event_by_id"], name: "index_scenes_on_world_event_by_id"
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
    t.string "mandatory_extra_keys", default: [], null: false, array: true
    t.string "optional_extra_keys", default: [], null: false, array: true
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
  add_foreign_key "alerts", "events", on_delete: :cascade
  add_foreign_key "alerts", "factions", on_delete: :cascade
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
  add_foreign_key "crafting_features", "characters", column: "proposed_by_id", on_delete: :nullify
  add_foreign_key "crafting_item_events", "accounts", column: "actor_id", on_delete: :nullify
  add_foreign_key "crafting_item_events", "characters", column: "other_character_id", on_delete: :nullify
  add_foreign_key "crafting_item_events", "characters", on_delete: :nullify
  add_foreign_key "crafting_item_events", "crafting_items", column: "item_id", on_delete: :nullify
  add_foreign_key "crafting_item_types", "soul_skills", on_delete: :nullify
  add_foreign_key "crafting_items", "characters", column: "maker_id", on_delete: :nullify
  add_foreign_key "crafting_items", "characters", on_delete: :cascade
  add_foreign_key "crafting_items", "crafting_catalogue_items", column: "catalogue_item_id", on_delete: :nullify
  add_foreign_key "crafting_items", "crafting_item_types", column: "item_type_id", on_delete: :nullify
  add_foreign_key "crafting_shop_listings", "crafting_catalogue_items", column: "catalogue_item_id", on_delete: :cascade
  add_foreign_key "crafting_shop_listings", "rooms", on_delete: :cascade
  add_foreign_key "crafting_trade_items", "crafting_items", column: "item_id", on_delete: :cascade
  add_foreign_key "crafting_trade_items", "crafting_trades", column: "trade_id", on_delete: :cascade
  add_foreign_key "crafting_trades", "characters", column: "from_character_id", on_delete: :cascade
  add_foreign_key "crafting_trades", "characters", column: "to_character_id", on_delete: :cascade
  add_foreign_key "crafting_trades", "scenes", on_delete: :nullify
  add_foreign_key "domains", "areas", on_delete: :nullify
  add_foreign_key "domains", "characters", column: "holder_character_id", on_delete: :nullify
  add_foreign_key "domains", "domains", column: "liege_id", on_delete: :nullify
  add_foreign_key "domains", "factions", column: "holder_faction_id", on_delete: :nullify
  add_foreign_key "economy_allowance_changes", "soul_bnbs", on_delete: :cascade
  add_foreign_key "economy_entries", "accounts", column: "actor_id", on_delete: :nullify
  add_foreign_key "economy_entries", "characters", column: "actor_character_id", on_delete: :nullify
  add_foreign_key "economy_entries", "economy_accounts", column: "account_id", on_delete: :cascade
  add_foreign_key "economy_entries", "economy_accounts", column: "counterparty_id", on_delete: :nullify
  add_foreign_key "economy_entries", "economy_schedules", column: "schedule_id", on_delete: :nullify
  add_foreign_key "economy_schedules", "accounts", column: "created_by_id", on_delete: :nullify
  add_foreign_key "economy_schedules", "characters", column: "created_by_character_id", on_delete: :nullify
  add_foreign_key "economy_schedules", "economy_accounts", column: "from_account_id", on_delete: :cascade
  add_foreign_key "economy_schedules", "economy_accounts", column: "to_account_id", on_delete: :cascade
  add_foreign_key "event_signups", "characters", on_delete: :cascade
  add_foreign_key "event_signups", "events", on_delete: :cascade
  add_foreign_key "events", "accounts", column: "created_by_id", on_delete: :nullify
  add_foreign_key "events", "characters", column: "host_id", on_delete: :nullify
  add_foreign_key "events", "rooms", on_delete: :cascade
  add_foreign_key "events", "scenes", on_delete: :nullify
  add_foreign_key "exits", "rooms", column: "destination_room_id"
  add_foreign_key "exits", "rooms", column: "source_room_id"
  add_foreign_key "faction_memberships", "characters", on_delete: :cascade
  add_foreign_key "faction_memberships", "factions", on_delete: :cascade
  add_foreign_key "faction_requests", "accounts", column: "decided_by_id", on_delete: :nullify
  add_foreign_key "faction_requests", "characters", on_delete: :cascade
  add_foreign_key "faction_requests", "factions", on_delete: :cascade
  add_foreign_key "forum_boards", "character_groups", on_delete: :cascade
  add_foreign_key "forum_posts", "accounts", on_delete: :nullify
  add_foreign_key "forum_posts", "characters", on_delete: :nullify
  add_foreign_key "forum_posts", "forum_topics", column: "topic_id", on_delete: :cascade
  add_foreign_key "forum_topics", "accounts", on_delete: :nullify
  add_foreign_key "forum_topics", "characters", on_delete: :nullify
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
  add_foreign_key "poses", "npcs", on_delete: :nullify
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
  add_foreign_key "scene_bounties", "accounts"
  add_foreign_key "scene_invitations", "characters"
  add_foreign_key "scene_invitations", "scenes"
  add_foreign_key "scene_participants", "characters"
  add_foreign_key "scene_participants", "scenes"
  add_foreign_key "scenes", "accounts", column: "world_event_by_id", on_delete: :nullify
  add_foreign_key "scenes", "characters", column: "finished_by_id", on_delete: :nullify
  add_foreign_key "scenes", "characters", column: "summary_by_id"
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
