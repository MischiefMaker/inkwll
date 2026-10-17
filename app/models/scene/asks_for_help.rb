# Two ticks a Chapter's players can put on it to get help from outside:
#
# - Storyteller wanted: lists the Chapter for players with the Storyteller
#   flag, so one can join and run it. Only for Chapters anyone can join, and
#   it comes off by itself when someone takes the Storyteller role.
# - Need a ruling: asks staff (those who handle reports) to rule on something,
#   with a short note. Staff can read the Chapter while it waits, even a
#   hidden one, and their ruling is written into it as a line from the game.
module Scene::AsksForHelp
  extend ActiveSupport::Concern

  RULING_NOTE_LENGTH = 300
  RULING_LENGTH = 1_000

  included do
    scope :storyteller_wanted, -> { open.visibility_joinable.where.not(storyteller_wanted_at: nil) }
    scope :ruling_wanted, -> { open.where.not(ruling_wanted_at: nil) }
  end

  def storyteller_wanted? = storyteller_wanted_at.present?
  def ruling_wanted? = ruling_wanted_at.present?

  def has_storyteller? = participants.any?(&:storyteller?)

  def can_want_storyteller?
    writable? && visibility_joinable? && !has_storyteller?
  end

  def want_storyteller!(by:)
    return false if storyteller_wanted? || !can_want_storyteller?
    update!(storyteller_wanted_at: Time.current)
    add_system_line!("#{by.name} asked for a #{Term[:storyteller]} to run this #{Term[:scene].downcase}.")
    true
  end

  def stop_wanting_storyteller!
    update!(storyteller_wanted_at: nil) if storyteller_wanted?
  end

  def ask_for_ruling!(by:, note:)
    note = note.to_s.squish.first(RULING_NOTE_LENGTH).presence
    return false if ruling_wanted? || !writable? || note.nil?
    update!(ruling_wanted_at: Time.current, ruling_note: note)
    add_system_line!("#{by.name} asked staff for a ruling: #{note}")
    StaffWaiting.refresh_bells!
    true
  end

  def withdraw_ruling!(by:)
    return false unless ruling_wanted?
    update!(ruling_wanted_at: nil, ruling_note: nil)
    add_system_line!("#{by.name} took back the request for a ruling.")
    StaffWaiting.refresh_bells!
    true
  end

  # Staff answer: the ruling goes into the Chapter as a line from the game.
  def give_ruling!(by:, ruling:)
    ruling = ruling.to_s.strip.first(RULING_LENGTH).presence
    return false unless ruling_wanted? && ruling
    update!(ruling_wanted_at: nil, ruling_note: nil)
    add_system_line!("Staff ruling from #{by.display_name}: #{ruling}")
    StaffWaiting.refresh_bells!
    true
  end

  # Staff who handle reports can read a Chapter while it waits for their ruling.
  def ruling_asked_of?(account)
    ruling_wanted? && account.present? && account.can?(:handle_reports)
  end
end
