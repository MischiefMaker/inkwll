# The Domains page: the tree of land and who holds each piece. Anyone,
# guests too, can see the tree; earnings and tax rates are only shown to a
# Domain's holder, its liege's holder and staff. A liege's holder sets the
# tax each of their vassals pays them.
class DomainsController < ApplicationController
  allow_previews only: :index
  before_action -> { raise ActiveRecord::RecordNotFound unless Domain.enabled? }
  limit_posting to: 30, within: 10.minutes, only: :update

  def index
    @domains = Domain.ordered.includes(:holder_character, :holder_faction, :area, :liege).to_a
    @vassals = @domains.group_by(&:liege_id)
    @sums = Domain.month_sums(@domains)
  end

  def update
    domain = Domain.find(params[:id])
    return redirect_to(domains_path, alert: "Only the holder of #{domain.liege&.name || "its liege"} and staff can set #{domain.name}'s tax.") unless domain.tax_settable_by?(current_account)
    if domain.update(tax_percent: params.dig(:domain, :tax_percent).to_i)
      redirect_to domains_path(anchor: "domain-#{domain.id}"), notice: "#{domain.name} now pays #{domain.tax_percent}% to #{domain.liege.name}."
    else
      redirect_to domains_path(anchor: "domain-#{domain.id}"), alert: domain.errors.full_messages.to_sentence
    end
  end
end
