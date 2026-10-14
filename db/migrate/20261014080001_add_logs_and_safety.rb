# Step 3: finishing Chapters, the Archives, reports, warnings, bans and
# notification settings.
class AddLogsAndSafety < ActiveRecord::Migration[8.1]
  def change
    change_table :scenes do |t|
      t.datetime :finished_at
      t.references :finished_by, foreign_key: { to_table: :characters, on_delete: :nullify }
      t.datetime :locked_at
      t.datetime :made_public_at
    end
    add_index :scenes, :finished_at

    change_table :scene_participants do |t|
      t.datetime :public_consent_at
      t.integer :notified_up_to, null: false, default: 0
    end

    add_column :poses, :hidden_by_staff_at, :datetime

    change_table :game_settings do |t|
      t.integer :idle_days, null: false, default: 7
      t.integer :auto_finish_days, null: false, default: 30
      t.boolean :block_vpns, null: false, default: false
    end

    change_table :accounts do |t|
      t.datetime :last_seen_at
      t.integer :email_after_days, null: false, default: 3
      t.boolean :email_only_my_turn, null: false, default: false
      t.string :browser_notifications, null: false, default: "off"
      t.integer :browser_notify_minutes, null: false, default: 5
    end

    create_table :reports do |t|
      t.references :scene, null: false, foreign_key: true
      t.references :pose, foreign_key: true
      t.references :account, null: false, foreign_key: true
      t.text :reason, null: false
      t.datetime :resolved_at
      t.references :resolved_by, foreign_key: { to_table: :accounts }
      t.text :resolution
      t.timestamps
    end

    create_table :account_warnings do |t|
      t.references :account, null: false, foreign_key: true
      t.references :staff, null: false, foreign_key: { to_table: :accounts }
      t.references :report, foreign_key: true
      t.text :body, null: false
      t.datetime :read_at
      t.timestamps
    end

    create_table :bans do |t|
      t.references :account, foreign_key: true
      t.cidr :ip_range
      t.text :reason, null: false
      t.references :banned_by, null: false, foreign_key: { to_table: :accounts }
      t.datetime :expires_at
      t.datetime :lifted_at
      t.timestamps
    end

    create_table :vpn_ranges do |t|
      t.cidr :range, null: false
    end
    add_index :vpn_ranges, :range, using: :gist, opclass: :inet_ops
  end
end
