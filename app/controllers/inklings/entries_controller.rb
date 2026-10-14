# Writing in an Inkling: an update everyone with access sees, a private
# entry (only you and staff, or for staff, one character), a personal note
# (only you), or a staff note (staff only).
class Inklings::EntriesController < Inklings::BaseController
  limit_posting to: 10, within: 1.minute

  def create
    kind = params[:kind].presence_in(%w[ public private personal gm ]) || "public"
    return back(alert: "Only staff can write staff notes.") if kind == "gm" && !staff_view?
    # Personal notes are only for yourself, so a locked Inkling still takes them.
    unless @inkling.writable_by?(current_account) || (kind == "personal" && !@inkling.closed?)
      return back(alert: @inkling.locked? ? "This is waiting for staff, so it's locked until they answer." : "You can't write in this.")
    end

    writer = staff_view? ? nil : writing_character
    private_to = (Character.find_by(id: params[:private_to_id]) || @inkling.character) if kind == "private" && staff_view?
    @inkling.add_entry!(account: current_account, character: writer, kind: kind, body: params[:body].to_s.strip, private_to: private_to)
    back(notice: "Added.")
  rescue ActiveRecord::RecordInvalid => e
    back(alert: e.record.errors.full_messages.to_sentence)
  end

  private
    # The player's character here: the Inkling's own, or the one it's shared with.
    def writing_character
      return @inkling.character if @inkling.owned_by?(current_account)
      mine = current_account.characters.active
      @inkling.shared_characters.where(id: mine.select(:id)).first ||
        mine.where(character_group_id: @inkling.shared_group_ids).first
    end
end
