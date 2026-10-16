# The owner cleared the Boons and Banes they'd added for testing and asked for
# the defaults on the next deploy. Runs once: it only does anything if the game
# has no active Boons or Banes left when it runs.
class RestoreStarterBoonsAndBanes < ActiveRecord::Migration[8.1]
  def up
    Soul::Bnb.reset_column_information
    restore! if Room.exists?
  end

  # Puts the starter Boons and Banes back when a game has deleted or retired
  # all of its own: names a game already has (even retired ones) are left alone.
  def restore!
    return if Soul::Bnb.active.exists?
    { "boon" => StarterContent::BOONS, "bane" => StarterContent::BANES }.each do |kind, entries|
      entries.each do |name, description|
        Soul::Bnb.create!(kind: kind, name: name, description: description) unless Soul::Bnb.exists?(kind: kind, name: name)
      end
    end
  end

  def down
  end
end
