# Activity emails, sent by Notifier and DigestJob. Each one carries an
# unsubscribe link (and header) that turns emails off without logging in.
class NotificationMailer < ApplicationMailer
  helper :application, :scenes

  def chapter_activity(participant, passages, more)
    @participant, @scene, @passages, @more = participant, participant.scene, passages, more
    notify participant.character.account,
      subject: "New #{Term[:pose, count: passages.size].downcase} in #{@scene.title}"
  end

  def your_turn(participant, passages, more)
    @participant, @scene, @passages, @more = participant, participant.scene, passages, more
    notify participant.character.account,
      subject: "Your turn in #{@scene.title}"
  end

  def mention(account, pose)
    @pose, @scene = pose, pose.scene
    notify account, subject: "#{pose.character.name} mentioned you in #{@scene.title}"
  end

  # entries: [participant, passages, more] for each Chapter.
  def digest(account, entries)
    @entries = entries
    notify account, subject: "What you've missed: #{entries.size} #{Term[:scene, count: entries.size].downcase}"
  end

  private
    def notify(account, subject:)
      @account = account
      @unsubscribe_url = unsubscribe_url(token: account.generate_token_for(:unsubscribe))
      headers["List-Unsubscribe"] = "<#{@unsubscribe_url}>"
      headers["List-Unsubscribe-Post"] = "List-Unsubscribe=One-Click"
      mail to: account.email, subject: subject
    end
end
