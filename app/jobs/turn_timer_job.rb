# Warns, and later skips, a player who hasn't taken their turn in time.
class TurnTimerJob < ApplicationJob
  queue_as :default
  discard_on ActiveJob::DeserializationError

  def perform(scene, token)
    scene.run_turn_timer!(token)
  end
end
