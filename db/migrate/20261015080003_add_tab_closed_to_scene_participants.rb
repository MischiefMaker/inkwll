class AddTabClosedToSceneParticipants < ActiveRecord::Migration[8.1]
  def change
    add_column :scene_participants, :tab_closed, :boolean, default: false, null: false
  end
end
