# A character's spells: learning them with XP and casting them.
module Character::GrimoireBook
  extend ActiveSupport::Concern

  included do
    has_many :learned_spells, class_name: "Grimoire::LearnedSpell", dependent: :delete_all
    has_many :spells, through: :learned_spells
    has_many :spell_proposals, class_name: "Grimoire::Proposal", dependent: :delete_all
  end

  def knows_spell?(spell) = learned_spells.exists?(spell: spell)

  # Why the character can't learn a spell yet, or nil if they can.
  def cannot_learn_reason(spell)
    if !spell.active? then "#{spell.name} can't be learned now."
    elsif knows_spell?(spell) then "#{name} already knows #{spell.name}."
    elsif sheet_open? then "Finish the starting sheet first."
    elsif rating_for(spell.branch.skill) < spell.minimum_rating
      "#{spell.name} needs #{spell.branch.skill.name} #{spell.minimum_rating}; #{name} has #{rating_for(spell.branch.skill)}."
    elsif spell.xp_cost > xp_available then "#{spell.name} costs #{spell.xp_cost} XP; #{name} has #{xp_available}."
    end
  end

  def learn_spell!(spell)
    with_lock do
      reason = cannot_learn_reason(spell)
      raise Character::SoulSheet::SheetError, reason if reason
      learned_spells.create!(spell: spell, xp_cost: spell.xp_cost)
      xp_entries.create!(kind: "spend", amount: -spell.xp_cost, trait: spell) if spell.xp_cost.positive?
      note_history!("spell_learned", "Learned the spell #{spell.name}.")
    end
  end
end
