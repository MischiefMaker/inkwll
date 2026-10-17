# Pays the Economy's scheduled payments and faction dues that are due today.
class EconomyDailyJob < ApplicationJob
  def perform(today = Date.current)
    Economy.run_due!(today)
  end
end
