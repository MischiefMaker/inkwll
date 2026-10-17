# Version 2.0: the Looking for RP flag. A player switches it on for a
# character with two short optional tags ("I am..." and "Looking for..."),
# and the character gets a mark in Here and Where and a place on the
# Looking for RP page until it's switched off.
class AddLookingForRpToCharacters < ActiveRecord::Migration[8.1]
  def change
    add_column :characters, :lfrp_at, :datetime
    add_column :characters, :lfrp_i_am, :string
    add_column :characters, :lfrp_looking_for, :string
    add_index :characters, :lfrp_at
  end
end
