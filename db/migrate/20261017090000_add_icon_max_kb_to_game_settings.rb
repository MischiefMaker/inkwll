# How big a player or character icon upload may be, set in Admin → Game
# settings (owner, 2026-10-17). Also makes the small chat-sized copy of every
# icon already uploaded, so the OOC Chat and Chapters don't wait on them.
class AddIconMaxKbToGameSettings < ActiveRecord::Migration[8.1]
  def up
    add_column :game_settings, :icon_max_kb, :integer, default: 1024, null: false

    [ Account, Character ].each do |model|
      model.reset_column_information
      model.joins(:icon_attachment).find_each do |record|
        record.icon.variant(:tiny).processed
      rescue StandardError => e
        say "Couldn't make a small icon for #{model.name} #{record.id}: #{e.message}"
      end
    end
  end

  def down
    remove_column :game_settings, :icon_max_kb
  end
end
