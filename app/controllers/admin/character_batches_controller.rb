# Retiring many characters at once, or putting many on the roster, from the
# tick boxes on the staff Characters page. Characters it doesn't fit (already
# retired or on the roster) are skipped.
class Admin::CharacterBatchesController < Admin::BaseController
  require_job :delete_characters
  require_job :review_apps
  limit_posting to: 10, within: 10.minutes, only: :create

  MAX = 200

  def create
    characters = Character.active.where(id: Array(params[:character_ids]).first(MAX)).order(:name).to_a
    characters.reject! { |character| character.on_roster? || character.preparing_for_roster? }
    return redirect_to(admin_characters_path, alert: "Tick at least one character in play first.") if characters.empty?

    case params[:decision]
    when "retire"
      characters.each do |character|
        character.retire!
        Soul::AuditEntry.record!("retire", "Retired #{character.name}", actor: current_account, character: character)
      end
      redirect_to admin_characters_path, notice: "Retired #{characters.map(&:name).to_sentence}."
    when "deceased"
      characters.each do |character|
        character.die!
        Soul::AuditEntry.record!("retire", "Marked #{character.name} as deceased", actor: current_account, character: character)
      end
      redirect_to admin_characters_path, notice: "Marked #{characters.map(&:name).to_sentence} as deceased."
    when "roster"
      characters.each { |character| character.put_on_roster! }
      redirect_to admin_characters_path, notice: "Put #{characters.map(&:name).to_sentence} on the roster."
    else
      redirect_to admin_characters_path, alert: "Pick what to do with them."
    end
  end
end
