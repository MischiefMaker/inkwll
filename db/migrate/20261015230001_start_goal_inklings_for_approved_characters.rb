# The owner asked for the Goals from approved characters' applications to
# become Goal Inklings on the next deploy. Newly approved characters already
# get one; this catches up the ones approved before. Safe to run twice.
class StartGoalInklingsForApprovedCharacters < ActiveRecord::Migration[8.1]
  def up
    [ ProfileField, Inkling ].each(&:reset_column_information)
    Character.start_goal_inklings! if Room.exists?
  end

  def down
  end
end
