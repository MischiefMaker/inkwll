# Games made before 2026-10-15 started with no SOUL Aspects or Skills, no
# Boons and Banes and no profile fields, so players couldn't fill in their
# sheet or application (owner). This adds the starter set to any part a game
# still has none of; parts staff already set up are left alone.
class AddStarterContent < ActiveRecord::Migration[8.1]
  def up
    [ Soul::Aspect, Soul::Skill, Soul::Bnb, ProfileField ].each(&:reset_column_information)
    StarterContent.install! if Room.exists?
  end

  def down
  end
end
