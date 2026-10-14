# The alerts bell: what happened in the player's Chapters. Opening the list
# marks everything read.
class AlertsController < ApplicationController
  def index
    @alerts = current_account.alerts.newest_first.includes(:scene, :inkling, :character).limit(Alert::SHOWN).to_a
    Alert.read_all!(current_account) if @alerts.any?(&:unread?)
  end
end
