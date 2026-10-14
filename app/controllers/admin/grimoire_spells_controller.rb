# Adding and changing spells. Spells are retired (made inactive) rather than
# deleted, since characters may know them.
class Admin::GrimoireSpellsController < Admin::BaseController
  include GrimoireRequired
  require_job :review_apps
  before_action :set_spell, only: %i[ edit update ]

  def create
    spell = Grimoire::Spell.new(spell_params.merge(created_by: current_account))
    if spell.save
      redirect_to admin_grimoire_path, notice: "#{spell.name} added."
    else
      redirect_to admin_grimoire_path, alert: spell.errors.full_messages.to_sentence
    end
  end

  def edit
  end

  def update
    if @spell.update(spell_params)
      redirect_to admin_grimoire_path, notice: "Saved."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private
    def set_spell
      @spell = Grimoire::Spell.find(params[:id])
    end

    def spell_params
      params.expect(grimoire_spell: [ :branch_id, :name, :description, :minimum_rating, :difficulty_name, :active ])
    end
end
