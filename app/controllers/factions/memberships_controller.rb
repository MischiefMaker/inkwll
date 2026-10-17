# Adding, changing and removing a faction's members. Its heads and staff add
# members and set their titles; only staff choose heads (and Bank managers)
# or remove a head.
# A player can take their own character out of a faction.
class Factions::MembershipsController < ApplicationController
  limit_posting to: 30, within: 10.minutes, only: :create
  before_action -> { raise ActiveRecord::RecordNotFound unless Faction.enabled? }
  before_action :set_faction
  before_action :require_manager, only: %i[ create update ]
  before_action :set_membership, only: %i[ update destroy ]

  def create
    character = Character.active.where(status: "approved").where("lower(name) = ?", params[:name].to_s.squish.downcase).first
    return back(alert: "There's no character called #{params[:name].to_s.squish}.") unless character
    membership = @faction.memberships.new(character: character, title: params[:title], secret: params[:secret] == "1")
    if membership.save
      back(notice: "#{character.name} joined #{@faction.name}.")
    else
      back(alert: "#{character.name} #{membership.errors.full_messages.to_sentence.downcase.delete_prefix("character ")}.")
    end
  end

  def update
    return back(alert: "Only staff can change a head.") if @membership.head? && !@staff
    changes = params.expect(faction_membership: [ :title, :secret, :head, :bank_manager ])
    changes.delete(:head) unless @staff
    changes.delete(:bank_manager) unless @staff
    if @membership.update(changes)
      back(notice: "Saved.")
    else
      back(alert: @membership.errors.full_messages.to_sentence)
    end
  end

  def destroy
    own = @membership.character.account_id == current_account.id
    unless own || (@faction.manageable_by?(current_account) && (!@membership.head? || @staff))
      return back(alert: "You can't remove #{@membership.character.name}.")
    end
    @membership.destroy!
    back(notice: "#{@membership.character.name} is no longer in #{@faction.name}.")
  end

  private
    def set_faction
      @faction = Faction.visible_to(current_account).find(params[:faction_id])
      @staff = Faction.staff?(current_account)
    end

    def set_membership
      @membership = @faction.memberships.find(params[:id])
      raise ActiveRecord::RecordNotFound unless @membership.visible_to?(current_account)
    end

    def require_manager
      back(alert: "Only #{@faction.name}'s heads and staff can do that.") unless @faction.manageable_by?(current_account)
    end

    def back(**flash)
      redirect_to faction_path(@faction), **flash
    end
end
