# A player learning a spell for their character, paying XP.
class Characters::SpellsController < Characters::BaseController
  include GrimoireRequired

  def create
    spell = Grimoire::Spell.find(params[:spell_id])
    @character.learn_spell!(spell)
    redirect_to character_path(@character, tab: "grimoire"), notice: "#{@character.name} learned #{spell.name}."
  rescue Character::SoulSheet::SheetError => e
    redirect_to character_path(@character, tab: "grimoire"), alert: e.message
  end
end
