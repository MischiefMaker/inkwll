# Grimoire for staff: branches of magic, the spells in them, and players'
# spell proposals.
class Admin::GrimoireController < Admin::BaseController
  include GrimoireRequired
  require_job :review_apps

  def show
    @branches = Grimoire::Branch.ordered.includes(:skill, spells: :learned_spells)
    @proposals = Grimoire::Proposal.pending.includes(:character, :branch).order(:created_at)
    @branch = Grimoire::Branch.new
    @spell = Grimoire::Spell.new(minimum_rating: 1, difficulty_name: "standard")
  end
end
