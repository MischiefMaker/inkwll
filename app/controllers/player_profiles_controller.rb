# A player editing their own player profile.
class PlayerProfilesController < ApplicationController
  def edit
    @player = current_account
  end

  def update
    @player = current_account
    if @player.update(params.expect(account: [ :about_me, :icon, :remove_icon ]))
      redirect_to player_path(@player.username), notice: "Saved."
    else
      render :edit, status: :unprocessable_entity
    end
  end
end
