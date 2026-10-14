# Runs once a day: finishes Chapters nobody has posted in for the game's
# auto-finish time (30 days by default).
class AutoFinishJob < ApplicationJob
  queue_as :default

  def perform
    Scene.abandoned.find_each { |scene| scene.finish!(by: nil) }
  end
end
