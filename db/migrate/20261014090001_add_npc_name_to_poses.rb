class AddNpcNameToPoses < ActiveRecord::Migration[8.1]
  def change
    add_column :poses, :npc_name, :string
  end
end
