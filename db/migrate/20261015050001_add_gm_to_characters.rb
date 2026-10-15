# A GM "character" lets staff and Storytellers post and run Chapters as
# their player, picked as GM under Playing as. It is kept out of every
# character list.
class AddGmToCharacters < ActiveRecord::Migration[8.0]
  def change
    add_column :characters, :gm, :boolean, default: false, null: false
  end
end
