# The SOUL page in the admin panel: the game's Aspects and Skills.
class Admin::SoulController < Admin::BaseController
  require_job :change_game_settings

  def show
    @aspects = Soul::Aspect.ordered.includes(:skills)
    @aspect = Soul::Aspect.new
    @skill = Soul::Skill.new
  end
end
