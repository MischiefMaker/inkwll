# Everyone who has said they're looking for RP, most recently first. Players
# who haven't been around for a week drop off (their flag stays on).
class LookingForRpController < ApplicationController
  allow_previews

  def index
    @characters = Character.looking_for_rp_now.includes(:room, :character_group, :account, icon_attachment: :blob)
      .order(lfrp_at: :desc).limit(200).select(&:can_play?)
    @mine = current_account ? current_account.characters.active.order(:name).select(&:can_play?) : []
  end
end
