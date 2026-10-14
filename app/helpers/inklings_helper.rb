module InklingsHelper
  def inkling_state_label(inkling)
    return "Closed" if inkling.closed?
    { "draft" => "Not sent to staff", "submitted" => "Waiting for staff", "needs_changes" => "Changes asked for", "approved" => "Approved" }
      .fetch(inkling.review_state)
  end

  # Who wrote an entry, as players see it.
  def inkling_entry_author(entry)
    if entry.kind == "system" then "Inkwll"
    elsif entry.character then entry.character.name
    elsif entry.account then "Staff (#{entry.account.display_name})"
    else "Someone who has left"
    end
  end

  def inkling_entry_label(entry)
    case entry.kind
    when "private" then entry.private_to ? "Private, for #{entry.private_to.name} and staff" : "Private, for staff"
    when "personal" then "Personal note, only you see this"
    when "gm" then "Staff note"
    when "roll" then entry.private? ? "Roll, for staff" : "Roll"
    when "reward" then entry.private? ? "Reward, for #{entry.private_to&.name} and staff" : "Reward"
    end
  end
end
