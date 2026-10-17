# Version 2.0: the census. Staff can mark a character group as needing players,
# with a short note, shown beside its count in the Character Directory.
class AddWantedToCharacterGroups < ActiveRecord::Migration[8.1]
  def change
    add_column :character_groups, :needs_players, :boolean, default: false, null: false
    add_column :character_groups, :wanted_note, :string
  end
end
