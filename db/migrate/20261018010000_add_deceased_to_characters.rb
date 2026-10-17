# Version 2.0: a Deceased status beside Retired, for the Graveyard page.
# A deceased character is also retired (it can't be played). The date is the
# game's in-character date, and the note is an optional epitaph.
class AddDeceasedToCharacters < ActiveRecord::Migration[8.1]
  def change
    add_column :characters, :deceased_on, :date
    add_column :characters, :deceased_note, :string
    add_index :characters, :deceased_on
  end
end
