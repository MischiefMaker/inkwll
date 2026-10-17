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

  # The published hook other systems use to offer extra Boons and Banes for
  # a character's rolls (Soul::RollExtra), such as item features from
  # Crafting. Each system registers once, by name:
  #   Soul.offer_roll_extras(:crafting) { |character| [...] }
  def self.roll_extra_sources = (@roll_extra_sources ||= {})

  def self.offer_roll_extras(name, &block)
    roll_extra_sources[name] = block
  end

  def self.roll_extras_for(character)
    roll_extra_sources.values.flat_map { |source| Array(source.call(character)) }
  end
end
