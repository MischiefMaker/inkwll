# Casting a learned spell in an Inkling, by the character it's about (or one it's
# shared with), for everyone with access or only for you and staff.
class Inklings::CastsController < Inklings::EntriesController
  include SoulRequired
  include GrimoireRequired

  def create
    return back(alert: "This is waiting for staff, so it's locked until they answer.") unless @inkling.writable_by?(current_account) && !staff_view?
    @inkling.cast!(writing_character, Grimoire::Spell.find(params[:spell_id]), by: current_account, private: params[:private] == "1")
    back(notice: "Cast.")
  rescue ArgumentError, KeyError => e
    back(alert: e.message)
  end
end
