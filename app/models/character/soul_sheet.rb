# A character's SOUL sheet: Resonance, Aspect and Skill ratings, and XP.
#
# While the sheet is open (before approval, or until the player finishes it
# when the game doesn't need approval) the player spends starting points
# freely. Once it's locked, Resonance is fixed and ratings rise only by
# spending XP.
module Character::SoulSheet
  extend ActiveSupport::Concern

  class SheetError < StandardError; end

  included do
    has_many :soul_ratings, class_name: "Soul::Rating", dependent: :delete_all
    has_many :xp_entries, class_name: "Soul::XpEntry", dependent: :delete_all
    has_many :soul_rolls, class_name: "Soul::Roll", dependent: :delete_all

    validates :resonance, numericality: { only_integer: true }
  end

  def sheet_open? = sheet_locked_at.nil?

  def rating_for(trait)
    soul_ratings.detect { |r| r.trait_type == trait.class.name && r.trait_id == trait.id }&.rating.to_i
  end

  def roll_base(skill)
    rating_for(skill) + Soul::Rules.aspect_bonus(rating_for(skill.aspect))
  end

  # --- Starting points -------------------------------------------------------

  def chargen_allowance = Soul::Rules.chargen_allowance(resonance)

  def skill_points_spent = soul_ratings.select { |r| r.trait_type == "Soul::Skill" }.sum(&:rating)
  def aspect_points_spent = soul_ratings.select { |r| r.trait_type == "Soul::Aspect" }.sum(&:rating)

  # Saves the starting sheet in one go: Resonance plus every rating, given as
  # { "aspect" => { id => rating }, "skill" => { id => rating } }. Checks the
  # totals and caps before saving anything.
  def set_starting_sheet!(resonance:, aspects: {}, skills: {})
    raise SheetError, "This sheet is locked. Raise ratings by spending XP." unless sheet_open?

    new_resonance = Soul::Rules.resonance_enabled? ? resonance.to_i : 0
    raise SheetError, "Resonance must be between #{Soul::Rules.resonance_range.min} and #{Soul::Rules.resonance_range.max}." unless Soul::Rules.resonance_range.cover?(new_resonance)
    allowance = Soul::Rules.chargen_allowance(new_resonance)

    aspect_values = Soul::Aspect.all.to_h { |aspect| [ aspect, aspects.to_h.fetch(aspect.id.to_s, 0).to_i ] }
    skill_values = Soul::Skill.all.to_h { |skill| [ skill, skills.to_h.fetch(skill.id.to_s, 0).to_i ] }

    aspect_values.each do |aspect, value|
      raise SheetError, "#{aspect.name} must be between 0 and #{aspect.max_rating}." unless value.between?(0, aspect.max_rating)
    end
    skill_values.each do |skill, value|
      raise SheetError, "#{skill.name} can start at #{allowance[:starting_cap]} at most." unless value.between?(0, allowance[:starting_cap])
    end
    if aspect_values.values.sum > allowance[:aspect_points]
      raise SheetError, "That's #{aspect_values.values.sum} Aspect points; you have #{allowance[:aspect_points]}."
    end
    if skill_values.values.sum > allowance[:skill_points]
      raise SheetError, "That's #{skill_values.values.sum} Skill points; you have #{allowance[:skill_points]}."
    end

    transaction do
      update!(resonance: new_resonance)
      aspect_values.merge(skill_values).each { |trait, value| store_rating!(trait, value) }
    end
  end

  # Locks Resonance and the starting ratings. Happens at approval, or when
  # the player finishes their sheet in a game without approval.
  def lock_sheet!
    update!(sheet_locked_at: Time.current) if sheet_open?
  end

  def unlock_sheet!
    update!(sheet_locked_at: nil)
  end

  # --- XP ----------------------------------------------------------------------

  def xp_available = xp_entries.sum("amount + catchup_amount")
  def xp_earned = xp_entries.where(kind: "award").sum(:amount)
  def xp_catchup_earned = xp_entries.sum(:catchup_amount)
  def xp_spent = -xp_entries.where(kind: "spend").sum(:amount)

  def raise_cost(trait)
    Soul::Rules.cost(new_rating: rating_for(trait) + 1, xp_spent: xp_spent, resonance: resonance, aspect: trait.aspect?)
  end

  # Raises an Aspect or Skill by one, paying XP.
  def spend_xp!(trait)
    raise SheetError, "Finish the starting sheet first." if sheet_open?
    with_lock do
      soul_ratings.reset
      new_rating = rating_for(trait) + 1
      raise SheetError, "#{trait.name} is already at its highest (#{trait.max_rating})." if new_rating > trait.max_rating
      cost = raise_cost(trait)
      raise SheetError, "Raising #{trait.name} to #{new_rating} costs #{cost} XP; #{name} has #{xp_available}." if cost > xp_available

      store_rating!(trait, new_rating)
      xp_entries.create!(kind: "spend", amount: -cost, trait: trait, new_rating: new_rating)
    end
  end

  # Gives XP. key makes repeated awards for the same thing (a Chapter, a
  # week) count once. Automatic awards add catch-up XP for characters behind
  # the median. When awarding many characters at once, work the median out
  # first and pass it in, so the ones awarded first don't raise it for the rest.
  def award_xp!(amount, source:, key: nil, actor: nil, note: nil, catchup: false, median: nil)
    return if amount.to_i <= 0 || (key && Soul::XpEntry.exists?(idempotency_key: key))
    bonus = catchup ? catchup_bonus(amount.to_i, median || self.class.median_xp_earned) : 0
    xp_entries.create!(kind: "award", source: source, amount: amount.to_i, catchup_amount: bonus, idempotency_key: key, actor: actor, note: note)
  rescue ActiveRecord::RecordNotUnique
    nil
  end

  # Staff fixing a mistake. The amount can be negative.
  def correct_xp!(amount, actor:, note:)
    xp_entries.create!(kind: "correction", amount: amount.to_i, actor: actor, note: note)
  end

  # --- Rolls -------------------------------------------------------------------

  # Rolls a Skill against a named difficulty. Returns an unsaved Soul::Roll
  # holding the result.
  def roll_skill(skill, difficulty_name, random: Random)
    difficulty = Soul::Rules.difficulties.fetch(difficulty_name.to_s) { raise SheetError, "Pick a difficulty." }
    skill_rating = rating_for(skill)
    bonus = Soul::Rules.aspect_bonus(rating_for(skill.aspect))
    chance = Soul::Dice.success_probability(0, difficulty - skill_rating - bonus)
    dice = Soul::Dice.roll(0, random: random)
    result = dice[:total] + skill_rating + bonus
    succeeded = result >= difficulty
    soul_rolls.new(skill: skill, skill_name: skill.name, difficulty_name: difficulty_name.to_s, difficulty: difficulty,
      skill_rating: skill_rating, aspect_bonus: bonus, dice: dice, result: result,
      degree: Soul::Rules.degree_for(result - difficulty), probability: succeeded ? chance : 1 - chance,
      extraordinary: Soul::Rules.extraordinary?(succeeded ? chance : 1 - chance))
  end

  private
    def store_rating!(trait, value)
      rating = soul_ratings.find_or_initialize_by(trait: trait)
      if value.zero?
        rating.destroy! if rating.persisted?
      else
        rating.update!(rating: value)
      end
      soul_ratings.reset
    end

    # Characters behind the median earn up to double on automatic awards,
    # but never past the median.
    def catchup_bonus(amount, median)
      settings = Soul::Rules.catchup
      return 0 unless settings["enabled"]
      progress = xp_earned + xp_catchup_earned
      return 0 unless progress < median
      [ [ amount * settings["multiplier"].to_f - amount, median - progress ].min, 0 ].max.floor
    end

  class_methods do
    # The median XP earned by approved characters.
    def median_xp_earned
      earned = Soul::XpEntry.award.group(:character_id).sum(:amount)
      values = where(status: "approved").pluck(:id).map { |id| earned.fetch(id, 0) }.sort
      return 0 if values.empty?
      mid = values.size / 2
      values.size.odd? ? values[mid] : (values[mid - 1] + values[mid]) / 2.0
    end
  end
end
