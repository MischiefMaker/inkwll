# Marks a Chapter as read up to a Passage. The page sends this while the player
# can actually see it, so Passages that arrive while they're away stay unread.
class Scenes::ReadingsController < Scenes::BaseController
  def update
    up_to = [ params[:up_to].to_i, @scene.last_sequence ].min
    changed = @scene.participants_for(current_account).map { |p| p.mark_read!(up_to) }.any?
    current_account.broadcast_chapter_tabs if changed
    head :no_content
  end
end
