# The Spirit Skill "Natural" is now "Natural Magic" (owner). Only renames it
# where staff haven't already changed the name themselves.
class RenameNaturalToNaturalMagic < ActiveRecord::Migration[8.1]
  def up
    execute "UPDATE soul_skills SET name = 'Natural Magic' WHERE key = 'natural' AND name = 'Natural'"
  end

  def down
  end
end
