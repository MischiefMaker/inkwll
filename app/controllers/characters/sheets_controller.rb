# A player setting their character's starting SOUL sheet: Resonance and
# the starting Aspect and Skill ratings.
class Characters::SheetsController < Characters::BaseController
  include SoulRequired

  def update
    sheet = params.fetch(:sheet, {})
    @character.set_starting_sheet!(resonance: sheet[:resonance],
      aspects: sheet.fetch(:aspects, {}).permit(*Soul::Aspect.ids.map(&:to_s)).to_h,
      skills: sheet.fetch(:skills, {}).permit(*Soul::Skill.ids.map(&:to_s)).to_h)
    redirect_to character_path(@character, tab: "soul"), notice: "Sheet saved."
  rescue Character::SoulSheet::SheetError => e
    redirect_to character_path(@character, tab: "soul"), alert: e.message
  end
end
