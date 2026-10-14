# A character's Boons and Banes. Players pick their own on a starting
# sheet; after that, staff grant, change and remove them.
class Characters::BnbsController < ApplicationController
  include SoulRequired
  limit_posting to: 20
  before_action :set_character
  before_action :require_staff_job, only: :update

  def create
    bnb = Soul::Bnb.active.find(params[:bnb_id])
    if staff?
      @character.add_bnb!(bnb, level: params[:level], skill_ids: params[:skill_ids], explanation: params[:explanation], source: "staff")
      Soul::AuditEntry.record!("bnb_grant", "Granted #{bnb.name} (#{params[:level].presence || "minor"})", actor: current_account, character: @character, reason: params[:reason])
    elsif mine? && @character.sheet_open? && bnb.starting?
      @character.add_bnb!(bnb, level: params[:level], skill_ids: params[:skill_ids], explanation: params[:explanation], source: "starting")
    else
      return head :forbidden
    end
    back notice: "#{bnb.name} added."
  rescue Character::SoulSheet::SheetError => e
    back alert: e.message
  end

  # Staff: progress, regress, resolve or restore.
  def update
    entry = @character.character_bnbs.find(params[:id])
    @character.change_bnb!(entry, params[:change].presence_in(%w[ progress regress resolve restore ]) || "progress", actor: current_account, reason: params[:reason])
    back notice: "#{entry.name} updated."
  rescue Character::SoulSheet::SheetError => e
    back alert: e.message
  end

  # Players drop picks from a starting sheet; staff can delete for good.
  def destroy
    entry = @character.character_bnbs.find(params[:id])
    if staff?
      entry.destroy!
      Soul::AuditEntry.record!("bnb_delete", "Deleted #{entry.name}", actor: current_account, character: @character, reason: params[:reason])
    elsif mine?
      @character.drop_starting_bnb!(entry)
    else
      return head :forbidden
    end
    back notice: "#{entry.name} removed."
  rescue Character::SoulSheet::SheetError => e
    back alert: e.message
  end

  private
    def set_character
      @character = Character.find(params[:character_id])
    end

    def mine? = @character.account_id == current_account.id
    def staff? = current_account.can?(:review_apps)

    def require_staff_job
      head :forbidden unless staff?
    end

    def back(**flash)
      redirect_to character_path(@character, tab: "soul"), **flash
    end
end
