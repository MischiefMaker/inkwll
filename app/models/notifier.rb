# Decides who gets an email about new activity, following each player's
# notification settings (see Account::EMAIL_NOTIFICATIONS):
#
# - every_time: an email as soon as there's something new.
# - when_away: the same, but only if they're still away AWAY_DELAY later.
# - after_days: one digest once they've been away email_after_days (DigestJob).
#
# Several new Passages in one Chapter make one email until the player reads
# it. Players who tick "only when it's my turn" get turn emails instead, in
# Chapters of three or more with a turn order. @mentions always email.
module Notifier
  AWAY_DELAY = 10.minutes
  PASSAGES_PER_EMAIL = 20

  module_function

  def passage_posted(pose)
    scene = pose.scene
    poster = pose.character.account

    scene.participants.includes(character: :account).each do |participant|
      account = participant.character.account
      next if account == poster || !account.wants_email? || account.only_turn_emails_for?(scene)

      case account.email_notifications
      when "every_time" then ChapterEmailJob.perform_later(participant)
      when "when_away" then ChapterEmailJob.set(wait: AWAY_DELAY).perform_later(participant, away_only: true)
      end
    end

    mentioned_characters(pose).each do |character|
      account = character.account
      next if account == poster || !account.wants_email? || !scene.readable_by?(account)
      NotificationMailer.mention(account, pose).deliver_later
    end
  end

  def turn_given(participant)
    scene = participant.scene
    account = participant.character.account
    return unless account.wants_email? && account.only_turn_emails_for?(scene)

    case account.email_notifications
    when "every_time" then TurnEmailJob.perform_later(participant, scene.turn_token)
    when "when_away" then TurnEmailJob.set(wait: AWAY_DELAY).perform_later(participant, scene.turn_token, away_only: true)
    end
  end

  # Sends one email about a Chapter, unless one was already sent since the
  # player last read it.
  def email_chapter(participant, away_only: false)
    account = participant.character.account
    return if participant.emailed_since_last_read? || (away_only && account.online?)

    passages = participant.unread_passages.to_a
    return if passages.empty?

    NotificationMailer.chapter_activity(participant, passages.last(PASSAGES_PER_EMAIL), passages.size - PASSAGES_PER_EMAIL).deliver_later
    participant.mark_emailed!
  end

  # Characters named after an @ in the Passage, like "@Wren" or "@Mary-Jane O'Neil".
  def mentioned_characters(pose)
    return Character.none unless pose.body.include?("@")
    Character.where("strpos(lower(?), '@' || lower(name)) > 0", pose.body).includes(:account)
  end
end
