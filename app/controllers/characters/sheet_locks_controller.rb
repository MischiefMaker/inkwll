# Locking a SOUL sheet fixes Resonance and the starting ratings. Approval
# locks it; in games without approval the player locks it themselves.
# Staff can unlock a sheet to fix it.
class Characters::SheetLocksController < ApplicationController
  include SoulRequired
  before_action :set_character

  def create
    unless current_account.can?(:review_apps) || (@character.account_id == current_account.id && !GameSetting.current.approval_required?)
      return redirect_to character_path(@character, tab: "soul"), alert: "Staff lock this sheet when they approve #{@character.name}."
    end
    @character.lock_sheet!
    Soul::AuditEntry.record!("sheet_lock", "Locked the sheet", actor: current_account, character: @character) unless @character.account_id == current_account.id
    redirect_to character_path(@character, tab: "soul"), notice: "Sheet finished. From now on, raise ratings by spending XP."
  end

  def destroy
    return head :forbidden unless current_account.can?(:review_apps)
    @character.unlock_sheet!
    Soul::AuditEntry.record!("sheet_unlock", "Unlocked the sheet", actor: current_account, character: @character)
    redirect_to character_path(@character, tab: "soul"), notice: "Sheet unlocked. The player can change it again."
  end

  private
    def set_character
      @character = Character.find(params[:character_id])
    end
end
