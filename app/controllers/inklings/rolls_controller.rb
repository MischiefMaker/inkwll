# A SOUL roll in an Inkling, by the character it's about (or one it's
# shared with), for everyone with access or only for you and staff.
class Inklings::RollsController < Inklings::EntriesController
  include SoulRequired

  def create
    return back(alert: "This is waiting for staff, so it's locked until they answer.") unless @inkling.writable_by?(current_account) && !staff_view?
    skill = Soul::Skill.find(params[:skill_id])
    @inkling.roll!(writing_character, skill, params[:difficulty], by: current_account, private: params[:private] == "1")
    back(notice: "Rolled.")
  rescue ArgumentError, KeyError => e
    back(alert: e.message)
  end
end
