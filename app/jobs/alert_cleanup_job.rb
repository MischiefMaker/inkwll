# Deletes alerts that were read more than a month ago.
class AlertCleanupJob < ApplicationJob
  def perform
    Alert.clean_up!
  end
end
