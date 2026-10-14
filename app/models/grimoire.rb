# Grimoire, the magic system, rebuilt from the owner's Grimoire plugin for
# AresMUSH. Each branch of magic is tied to a SOUL Skill. Characters learn
# spells from a branch by paying XP, once their rating in its Skill is high
# enough, and cast them in Chapters as SOUL rolls. Players can propose new
# spells for staff to approve. It needs SOUL, and is off until a game
# switches it on.
module Grimoire
  def self.table_name_prefix = "grimoire_"

  def self.enabled?
    settings = GameSetting.current
    settings.grimoire_enabled? && settings.soul_enabled?
  end

  def self.xp_cost_per_rating
    Rails.application.config_for(:grimoire)[:xp_cost_per_rating].to_i.clamp(0, 100)
  end
end
