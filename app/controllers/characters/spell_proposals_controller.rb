# A player proposing a new spell for staff to approve.
class Characters::SpellProposalsController < Characters::BaseController
  include GrimoireRequired
  limit_posting to: 5, within: 1.hour

  def create
    proposal = @character.spell_proposals.new(params.expect(grimoire_proposal: [ :branch_id, :name, :description, :minimum_rating, :difficulty_name ]))
    if proposal.save
      redirect_to character_path(@character, tab: "grimoire"), notice: "Sent #{proposal.name} to staff."
    else
      redirect_to character_path(@character, tab: "grimoire"), alert: proposal.errors.full_messages.to_sentence
    end
  end
end
