# Rolls and staff rewards in an Inkling. Rewards go through SOUL: XP, a new
# Boon or Bane, progressing one the character has, or a Culmination. A
# plain note works without SOUL.
module Inkling::Outcomes
  extend ActiveSupport::Concern

  REWARDS = %w[ xp bnb progress culmination note ].freeze

  # A SOUL roll by the Inkling's character (or one it's shared with), shown
  # to everyone with access, or only to the roller and staff.
  def roll!(roller, skill, difficulty_name, by:, private: false)
    raise ArgumentError, "Rolls are switched off in this game." unless Soul.enabled?
    roll = roller.roll_skill(skill, difficulty_name)
    roll.save!
    text = "#{roller.name} rolls #{skill.name} against #{difficulty_name.to_s.humanize} (#{roll.difficulty})" \
      "#{" with #{roll.applied_text}" if roll.applied.any?} and gets #{roll.result}. " \
      "#{"Extraordinary! " if roll.extraordinary?}#{roll.degree_text}"
    add_entry!(account: by, character: roller, kind: "roll", body: text, private: private, soul_roll: roll, unless_locked: true)
  rescue Character::SoulSheet::SheetError => e
    raise ArgumentError, e.message
  end

  # Staff granting something for this Inkling. Returns the entry recording it.
  def reward!(by:, type:, amount: nil, bnb: nil, level: nil, entry: nil, title: nil, note: nil, private: true)
    raise ArgumentError, "Pick a kind of reward." unless type.in?(REWARDS)
    raise ArgumentError, "That reward needs SOUL, which is switched off." if type != "note" && !Soul.enabled?

    transaction do
      text = case type
      when "xp"
        amount = amount.to_i
        raise ArgumentError, "XP must be a positive number." unless amount.positive?
        character.award_xp!(amount, source: "inkling", actor: by, note: "#{type_name}: #{title.presence || self.title}".first(200))
        "#{amount} XP"
      when "bnb"
        raise ArgumentError, "Pick a Boon or Bane." unless bnb
        character.add_bnb!(bnb, level: level, skill_ids: nil, explanation: note.presence || "From the #{type_name} \"#{self.title}\".", source: "inkling")
        "#{bnb.name} (#{level.to_s.presence&.capitalize || "Minor"} #{bnb.kind.capitalize})"
      when "progress"
        raise ArgumentError, "Pick which Boon or Bane progresses." unless entry && entry.character_id == character_id
        character.change_bnb!(entry, "progress", actor: by, reason: "From the #{type_name} \"#{self.title}\".")
        "#{entry.name} progresses"
      when "culmination"
        raise ArgumentError, "A Culmination needs a title." if title.blank?
        culmination = character.culminations.create!(title: title, description: note, status: "approved", reviewed_by: by, reviewed_at: Time.current)
        character.note_history!("culmination", "Reached the Culmination \"#{culmination.title}\".")
        "the Culmination \"#{culmination.title}\""
      when "note"
        raise ArgumentError, "Write what the reward is." if note.blank?
        note
      end
      Soul::AuditEntry.record!("inkling_reward", "Reward from Inkling #{id}: #{text}", actor: by, character: character) if Soul.enabled?
      add_entry!(account: by, kind: "reward", body: "Reward for #{character.name}: #{text}.", private: private, private_to: character)
    end
  rescue Character::SoulSheet::SheetError, ActiveRecord::RecordInvalid => e
    raise ArgumentError, e.message
  end
end
