# See the emails in development at http://localhost:3000/rails/mailers
class NotificationMailerPreview < ActionMailer::Preview
  def chapter_activity
    participant = SceneParticipant.first
    NotificationMailer.chapter_activity(participant, participant.scene.poses.passage.last(3), 0)
  end

  def your_turn
    participant = SceneParticipant.first
    NotificationMailer.your_turn(participant, participant.scene.poses.passage.last(2), 4)
  end

  def mention
    pose = Pose.passage.last
    NotificationMailer.mention(Account.first, pose)
  end

  def digest
    entries = SceneParticipant.limit(2).map { |participant| [ participant, participant.scene.poses.passage.last(2), 0 ] }
    NotificationMailer.digest(Account.first, entries)
  end
end
