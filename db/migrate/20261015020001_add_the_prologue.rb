# New characters start in an out-of-character Setting, The Prologue, instead
# of an in-character one (owner, 2026-10-15). New games get it from the
# seeds; this adds it to games that already have Settings. Existing
# characters stay where they are.
class AddThePrologue < ActiveRecord::Migration[8.1]
  def up
    Room.reset_column_information
    Area.reset_column_information
    Room.create_prologue! if Room.exists?
  end

  def down
  end
end
