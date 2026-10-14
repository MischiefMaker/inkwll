# Game-wide switches that each game can change from the admin panel.
# There is only ever one row; use GameSetting.current.
class GameSetting < ApplicationRecord
  def self.current
    first || create!
  end
end
