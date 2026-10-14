# A player spending XP to raise an Aspect or Skill by one.
class Characters::XpSpendsController < Characters::BaseController
  include SoulRequired

  def create
    trait = (params[:trait_type] == "aspect" ? Soul::Aspect : Soul::Skill).find(params[:trait_id])
    @character.spend_xp!(trait)
    redirect_to character_path(@character, tab: "soul"), notice: "#{trait.name} is now #{@character.rating_for(trait)}."
  rescue Character::SoulSheet::SheetError => e
    redirect_to character_path(@character, tab: "soul"), alert: e.message
  end
end
