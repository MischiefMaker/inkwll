# Version 2.0: two ticks on a Chapter that put it on a list. "Storyteller
# wanted" lists it for players with the Storyteller flag, and "Need a ruling"
# asks staff to rule on something, with a short note saying what.
class AddStorytellerWantedAndRulingsToScenes < ActiveRecord::Migration[8.1]
  def change
    add_column :scenes, :storyteller_wanted_at, :datetime
    add_column :scenes, :ruling_wanted_at, :datetime
    add_column :scenes, :ruling_note, :string
    add_index :scenes, :storyteller_wanted_at
    add_index :scenes, :ruling_wanted_at
  end
end
