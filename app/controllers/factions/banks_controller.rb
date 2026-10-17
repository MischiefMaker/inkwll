# A faction's taxes and dues, set by its Bank managers (and staff) within
# the limits staff set in Admin → Economy. Only when taxes are switched on.
class Factions::BanksController < Factions::BankBaseController
  def update
    return back(alert: "Taxes are switched off in this game.") unless Economy.taxes_enabled?
    changes = params.expect(faction: %i[ income_tax_percent dues_amount dues_interval dues_next_on ])
    starts = (Date.parse(changes[:dues_next_on].to_s) rescue nil)
    changes[:dues_next_on] = starts && starts >= Date.current ? starts : (@faction.dues_next_on.presence || Date.tomorrow)
    if @faction.update(changes)
      back(notice: "Taxes saved.")
    else
      back(alert: @faction.errors.full_messages.to_sentence)
    end
  end
end
