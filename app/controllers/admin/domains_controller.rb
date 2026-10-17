# Admin → Domains: making the land, choosing who holds each piece, and
# setting its people and yield as the story goes. Wellkeepers only, since it
# makes money.
class Admin::DomainsController < Admin::BaseController
  require_job :change_game_settings
  before_action -> { raise ActiveRecord::RecordNotFound unless Domain.enabled? }
  before_action :set_domain, only: %i[ edit update destroy ]

  def index
    @domains = Domain.ordered.includes(:holder_character, :holder_faction, :liege, :area)
    @domain = Domain.new
    @game_setting = GameSetting.current
  end

  def create
    @domain = Domain.new(domain_params)
    @domain.position = Domain.maximum(:position).to_i + 1
    if set_holder && @domain.save
      redirect_to admin_domains_path, notice: "#{@domain.name} added."
    else
      @domains = Domain.ordered
      @game_setting = GameSetting.current
      render :index, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    @domain.assign_attributes(domain_params)
    if set_holder && @domain.save
      redirect_to admin_domains_path, notice: "Saved."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @domain.destroy
    redirect_to admin_domains_path, notice: "#{@domain.name} deleted. Its vassals now have no liege."
  end

  private
    def set_domain
      @domain = Domain.find(params[:id])
    end

    def domain_params
      params.require(:domain).permit(:name, :rank, :description, :liege_id, :holder_faction_id, :area_id, :people, :yield_per_head, :tax_percent, :position)
    end

    # The holder is typed as a character's name; a faction is picked from a
    # list instead, and only one of the two can be set.
    def set_holder
      name = params.dig(:domain, :holder_name).to_s.squish
      @holder_name = name
      if name.blank?
        @domain.holder_character = nil
        return true
      end
      character = Character.where(retired_at: nil).where("lower(name) = ?", name.downcase).first
      @domain.holder_character = character
      @domain.errors.add(:base, "There's no character called #{name}.") unless character
      character.present?
    end
end
