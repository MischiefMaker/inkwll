# Roster take-overs, configurable per game (owner, 2026-10-14): claim and
# play without staff review, redo the whole application, and/or answer some
# profile questions afresh.
class AddRosterOptions < ActiveRecord::Migration[8.1]
  def change
    add_column :game_settings, :roster_claim, :boolean, default: false, null: false
    add_column :game_settings, :roster_resubmit, :boolean, default: false, null: false
    add_column :profile_fields, :ask_on_roster, :boolean, default: false, null: false
    add_column :roster_applications, :answers, :jsonb, default: {}, null: false
  end
end
