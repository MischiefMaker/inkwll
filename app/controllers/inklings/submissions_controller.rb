# The player sending an Inkling to staff. It locks until staff answer.
class Inklings::SubmissionsController < Inklings::BaseController
  limit_posting to: 5, within: 10.minutes

  def create
    return back(alert: "Only #{@inkling.character.name}'s player can send this to staff.") unless @inkling.owned_by?(current_account)
    @inkling.submit!(by: @inkling.character)
    back(notice: "Sent to staff. It's locked until they answer.")
  rescue ArgumentError => e
    back(alert: e.message)
  end
end
