# A player proposing a new item feature for staff to approve or decline,
# like a Grimoire spell proposal.
class Characters::FeatureProposalsController < Characters::BaseController
  include CraftingRequired
  limit_posting to: 5, within: 1.hour

  def create
    return back(alert: "#{@character.name} can't propose features until they're approved.") unless @character.approved? && !@character.retired?
    feature = Crafting::Feature.new(params.expect(feature: [ :name, :description, :level, skill_ids: [], item_type_ids: [] ]))
    feature.assign_attributes(status: "proposed", proposed_by: @character)
    feature.level = "minor" unless feature.level.in?(Crafting.levels)
    if feature.save
      back(notice: "#{feature.name} has gone to staff. It shows here once they approve it.")
    else
      back(alert: feature.errors.full_messages.to_sentence)
    end
  end

  private
    def back(**flash)
      redirect_to new_character_craft_path(@character, anchor: "propose"), **flash
    end
end
