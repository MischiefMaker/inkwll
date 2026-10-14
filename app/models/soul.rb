# SOUL: the character system. Aspects and Skills, Resonance, XP and rolls.
# Rebuilt for Inkwll from the SOUL plugin for AresMUSH
# (github.com/MischiefMaker/ares-soul-plugin). Its numbers live in
# config/soul.yml; the Aspects and Skills are set by staff in the admin panel.
module Soul
  def self.table_name_prefix
    "soul_"
  end

  def self.enabled?
    GameSetting.current.soul_enabled?
  end
end
