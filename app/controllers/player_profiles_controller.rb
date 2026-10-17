# A player editing their own player profile.
class PlayerProfilesController < ApplicationController
  limit_posting to: 20, within: 1.hour, only: :update, name: "uploads"
  def edit
    @player = current_account
  end

  def update
    @player = current_account
    if @player.update(params.expect(account: [ :display_name, :about_me, :icon, :remove_icon, :away_until, :away_note ]))
      redirect_to player_path(@player.username), notice: "Saved."
    else
      render :edit, status: :unprocessable_entity
    end
  end
end
