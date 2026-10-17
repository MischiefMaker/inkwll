# One-off: games started before the sample map had streets get them now (the
# same streets new games are seeded with). It only adds to a map that still
# has the sample places, never changes anything else, and does nothing a
# second time. See StarterStreets.
class AddStreetsToTheStartingMap < ActiveRecord::Migration[8.1]
  def up
    StarterStreets.install!
  end

  def down; end
end
