# Staff putting characters on the roster: a new one nobody owns yet, a
# player's character they asked to give up, or any character staff decide
# should go on it. Declining a player's request leaves the character with them.
class Admin::RosterCharactersController < Admin::BaseController
  require_job :review_apps
  limit_posting to: 20, within: 10.minutes, only: :create

  def create
    attributes = params.expect(character: [ :name, :description, :roster_note ])
    character = Character.create_for_roster!(**attributes.to_h.symbolize_keys)
    redirect_to character_path(character),
      notice: "#{character.name} is ready to fill in. Players can't see them until you open them on the roster."
  rescue ActiveRecord::RecordInvalid => e
    redirect_to admin_roster_path, alert: e.record.errors.full_messages.to_sentence
  end

  def update
    if params[:decision] == "open"
      character = Character.find(params[:id])
      return redirect_to admin_roster_path, alert: "#{character.name} isn't waiting to go on the roster." unless character.preparing_for_roster?
      character.open_on_roster!
      return redirect_to character_path(character), notice: "#{character.name} is on the roster. Players can apply now."
    end

    character = Character.active.find(params[:id])
    if params[:decision] == "decline"
      character.update!(roster_requested_at: nil)
      redirect_to admin_roster_path, notice: "#{character.name} stays with their player."
    else
      character.put_on_roster!(note: params[:roster_note])
      redirect_to admin_roster_path, notice: "#{character.name} is on the roster."
    end
  end
end
