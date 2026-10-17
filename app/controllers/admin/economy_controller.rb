# Admin → Economy: the money's name, the starting amount and allowance,
# taxes, Boons and Banes that change the allowance, game payments, giving or
# taking money, and every recent movement of money. Staff who review
# applications run it; only Wellkeepers change its settings.
class Admin::EconomyController < Admin::BaseController
  include EconomyRequired
  require_job :review_apps
  require_job :change_game_settings, only: :update

  def show
    @game_setting = GameSetting.current
    @schedules = Economy::Schedule.running.where(from_account_id: nil).includes(to_account: :owner).order(:next_due_on)
    @changes = Economy::AllowanceChange.includes(:bnb).order(:amount)
    @entries = Economy::Entry.newest_first.includes(:actor, :actor_character, account: :owner, counterparty: :owner).limit(100)
  end

  def update
    @game_setting = GameSetting.current
    if @game_setting.update(params.expect(game_setting: %i[ currency_one currency_other currency_symbol economy_starting_amount economy_allowance
        economy_taxes_enabled economy_tax_max_percent economy_dues_max ]))
      redirect_to admin_economy_path, notice: "Saved."
    else
      show
      render :show, status: :unprocessable_entity
    end
  end
end
