# The player list, and player profiles: the out-of-character side of a player. They list the
# player's characters only when the game shows who plays which character
# (and always to staff and the player themselves).
class PlayersController < ApplicationController
  allow_previews

  # Everyone playing, by name and picture only. Never who they play, so it can't
  # give away an alt; the profile page decides what else to show.
  def index
    @players = Account.where(system: false, archived_at: nil).includes(icon_attachment: :blob).order(Arel.sql("lower(display_name)")).limit(1000)
  end

  def show
    @player = Account.find_by!(username: params[:name].to_s.downcase)
    @show_characters = GameSetting.current.players_public? || @player == current_account || current_account&.staff?
  end
end
