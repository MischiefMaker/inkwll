# Player profiles: the out-of-character side of a player. They list the
# player's characters only when the game shows who plays which character
# (and always to staff and the player themselves).
class PlayersController < ApplicationController
  def show
    @player = Account.find_by!(username: params[:name].to_s.downcase)
    @show_characters = GameSetting.current.players_public? || @player == current_account || current_account.staff?
  end
end
