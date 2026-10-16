# SOUL extras on a character: Boons and Banes, Culminations, the Narrative
# History the player sees, and the staff audit trail.
module Character::SoulExtras
  extend ActiveSupport::Concern

  included do
    has_many :character_bnbs, class_name: "Soul::CharacterBnb", dependent: :delete_all
    has_many :bnb_requests, class_name: "Soul::BnbRequest", dependent: :delete_all
    has_many :culminations, class_name: "Soul::Culmination", dependent: :delete_all
    has_many :history_entries, class_name: "Soul::HistoryEntry", dependent: :delete_all
    has_many :pending_rolls, class_name: "Soul::PendingRoll", dependent: :delete_all
  end

  def note_history!(event, narrative)
    history_entries.create!(event: event, narrative: narrative)
  end

  # --- Boons and Banes ---------------------------------------------------------

  def active_bnbs = character_bnbs.unresolved.includes(:bnb)
  def bnbs_for(skill) = active_bnbs.select { |entry| entry.affects?(skill) }

  # Gives the character a Boon or Bane. On a starting sheet the Resonance
  # limits apply; a Boon always needs enough Banes beside it.
  def add_bnb!(bnb, level:, skill_ids:, explanation:, source:, actor: nil)
    raise Character::SoulSheet::SheetError, "#{bnb.name} isn't available." unless bnb.active?
    level = level.to_s.presence || "minor"
    skill_ids = Array(skill_ids).compact_blank.map(&:to_i).presence || bnb.skill_ids
    check_bnb_limits!(bnb, level, starting: source == "starting")

    entry = character_bnbs.create!(bnb: bnb, level: level, skill_ids: skill_ids, explanation: explanation, source: source)
    note_history!("bnb_gained", "Gained #{bnb.name} (#{level.capitalize}).") unless source == "starting"
    entry
  rescue ActiveRecord::RecordInvalid => e
    raise Character::SoulSheet::SheetError, e.record.errors.full_messages.to_sentence
  end

  def drop_starting_bnb!(entry)
    raise Character::SoulSheet::SheetError, "Only a starting sheet's Boons and Banes can be dropped." unless sheet_open? && entry.source == "starting"
    entry.destroy!
  end

  # When the sheet locks, starting Boons and Banes go into the history.
  def note_starting_bnbs!
    character_bnbs.includes(:bnb).where(source: "starting").find_each do |entry|
      note_history!("bnb_gained", "Began with #{entry.name} (#{entry.level.capitalize}).")
    end
  end

  # Staff moving a Boon or Bane up or down a level, resolving it (it stops
  # counting but stays on record) or restoring it.
  def change_bnb!(entry, change, actor:, reason: nil)
    levels = Soul::Rules.bnb_levels.keys
    case change
    when "progress", "regress"
      raise Character::SoulSheet::SheetError, "Restore it first." if entry.resolved?
      # Progress is always good for the character: a Boon grows, a Bane fades.
      step = (change == "progress") == entry.boon? ? 1 : -1
      new_level = levels[levels.index(entry.level) + step]
      raise Character::SoulSheet::SheetError, "#{entry.name} can't go further that way." if new_level.nil? || levels.index(entry.level) + step < 0
      entry.update!(level: new_level)
      note_history!("bnb_changed", "#{entry.name} became #{new_level.capitalize}.")
    when "resolve"
      entry.update!(resolved_at: Time.current)
      note_history!("bnb_resolved", "#{entry.name} was resolved.")
    when "restore"
      entry.update!(resolved_at: nil)
      note_history!("bnb_restored", "#{entry.name} returned.")
    else
      raise ArgumentError, change
    end
    Soul::AuditEntry.record!("bnb_#{change}", "#{change.capitalize}: #{entry.name} (now #{entry.level}#{", resolved" if entry.resolved?})",
      actor: actor, character: self, reason: reason)
  end

  # --- Culminations ------------------------------------------------------------

  private
    def check_bnb_limits!(bnb, level, starting:)
      active = active_bnbs.to_a
      if bnb.boon?
        boons = active.count(&:boon?) + 1
        needed = Soul::Rules.banes_needed(boons)
        if active.count(&:bane?) < needed
          raise Character::SoulSheet::SheetError, "#{name} needs #{needed} #{"Bane".pluralize(needed)} for #{boons} #{"Boon".pluralize(boons)}. Add a Bane first."
        end
      end
      return unless starting

      limits = Soul::Rules.starting_limits(resonance, bnb.kind)
      same_kind = active.select { |entry| entry.kind == bnb.kind }
      label = bnb.kind.capitalize.pluralize
      if limits["max"] && same_kind.size + 1 > limits["max"]
        raise Character::SoulSheet::SheetError, "A starting sheet at Resonance #{resonance} can have #{limits["max"]} #{label} at most."
      end
      if limits.key?(level) && same_kind.count { |entry| entry.level == level } + 1 > limits[level].to_i
        raise Character::SoulSheet::SheetError, "A starting sheet at Resonance #{resonance} can have #{limits[level]} #{level.capitalize} #{label} at most."
      end
    end
end
