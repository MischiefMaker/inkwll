# An extra Boon or Bane another system offers for a character's rolls, such
# as a sword's "Well-balanced" feature (Crafting). It shows as a tick box in
# the roll box beside the character's own Boons and Banes and counts the
# same way, but SOUL's own Boons and Banes list is untouched. `always` ones
# (an item's flaw) count whenever they're tied to the Skill rolled.
Soul::RollExtra = Struct.new(:key, :name, :kind, :level, :skill_ids, :always, keyword_init: true) do
  def modifier = Soul::Rules.bnb_levels.fetch(level, 0) * (kind == "boon" ? 1 : -1)
  def affects?(skill) = skill_ids.include?(skill.id)
  def always? = always
end
