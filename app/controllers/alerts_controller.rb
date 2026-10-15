# The alerts bell: what happened in the player's Chapters. Opening the list
# marks everything read.
# The header's bell shows this list in a drop-down (a Turbo frame), so
# that request skips the page layout.
class AlertsController < ApplicationController
  layout -> { false if turbo_frame_request? }

  def index
    @alerts = current_account.alerts.newest_first.includes(:scene, :inkling, :character).limit(Alert::SHOWN).to_a
    Alert.read_all!(current_account) if @alerts.any?(&:unread?)
  end
end
