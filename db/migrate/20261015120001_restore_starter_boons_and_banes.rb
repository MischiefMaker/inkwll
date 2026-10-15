# The owner cleared the Boons and Banes they'd added for testing and asked for
# the defaults on the next deploy. Runs once: it only does anything if the game
# has no active Boons or Banes left when it runs.
class RestoreStarterBoonsAndBanes < ActiveRecord::Migration[8.1]
  def up
    Soul::Bnb.reset_column_information
    StarterContent.restore_bnbs! if Room.exists?
  end

  def down
  end
end
