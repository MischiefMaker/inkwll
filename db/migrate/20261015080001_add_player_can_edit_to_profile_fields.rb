class AddPlayerCanEditToProfileFields < ActiveRecord::Migration[8.1]
  def up
    add_column :profile_fields, :player_can_edit, :boolean, default: true, null: false
    execute "UPDATE profile_fields SET player_can_edit = FALSE WHERE name = 'Background'"
  end

  def down
    remove_column :profile_fields, :player_can_edit
  end
end
