require "test_helper"

class EconomyTest < ActionDispatch::IntegrationTest
  # Alice plays Wren and Moth, Bob plays Sable, Scribe plays Lark.
  setup do
    GameSetting.current.update!(economy_enabled: true, factions_enabled: true)
    @guild = Faction.create!(name: "Weavers' Guild")
    @wren = characters(:wren)
    @sable = characters(:sable)
  end

  def give(character, amount)
    character.purse.credit!(amount, kind: "staff", note: "Test money")
  end

  test "the economy is switched off until a game turns it on" do
    GameSetting.current.update!(economy_enabled: false)
    sign_in_as(accounts(:alice))
    get character_path(@wren, tab: "purse")
    assert_select ".purse", count: 0
    post character_payments_path(@wren), params: { to: "Sable", amount: 1 }
    assert_response :not_found
  end

  test "only the player and staff see a purse" do
    give(@wren, 10)
    sign_in_as(accounts(:bob))
    get character_path(@wren, tab: "purse")
    assert_select ".purse", count: 0

    sign_in_as(accounts(:alice))
    get character_path(@wren, tab: "purse")
    assert_select ".purse__amount", text: "10 crowns"

    sign_in_as(accounts(:scribe))
    get character_path(@wren, tab: "purse")
    assert_select ".purse__amount", text: "10 crowns"
  end

  test "a player pays another character and both ledgers show it" do
    give(@wren, 10)
    sign_in_as(accounts(:alice))
    post character_payments_path(@wren), params: { to: "sable", amount: 4, note: "For the ribbon" }
    assert_redirected_to character_path(@wren, tab: "purse")
    assert_equal 6, @wren.purse.reload.balance
    assert_equal 4, @sable.purse.reload.balance
    entry = @sable.purse.entries.last
    assert_equal "payment", entry.kind
    assert_equal "For the ribbon", entry.note
    assert_equal "Sable", @wren.purse.entries.last.counterparty.owner_name
    assert Alert.exists?(account: accounts(:bob), kind: "money")
  end

  test "nobody can pay more than they have, or from someone else's purse" do
    give(@wren, 3)
    sign_in_as(accounts(:alice))
    post character_payments_path(@wren), params: { to: "Sable", amount: 5 }
    assert_equal 3, @wren.purse.reload.balance
    assert_match "doesn't have", flash[:alert]

    sign_in_as(accounts(:bob))
    post character_payments_path(@wren), params: { to: "Sable", amount: 1 }
    assert_response :not_found
    assert_equal 3, @wren.purse.reload.balance
  end

  test "a payment can show in a chapter as a passage" do
    give(@wren, 10)
    sign_in_as(accounts(:alice))
    post character_payments_path(@wren), params: { to: "Sable", amount: 2, scene_id: scenes(:duel).id }
    assert scenes(:duel).poses.roll.exists?(character: @wren, body: "Wren hands Sable 2 crowns.")
  end

  test "a scheduled payment goes through on its day, and is skipped when it can't be paid" do
    give(@wren, 5)
    sign_in_as(accounts(:alice))
    post character_payment_schedules_path(@wren), params: { to: "Sable", amount: 3, interval: "week", starts_on: Date.tomorrow }
    schedule = Economy::Schedule.last
    assert_equal Date.tomorrow, schedule.next_due_on

    Economy.run_due!(Date.tomorrow)
    assert_equal 2, @wren.purse.reload.balance
    assert_equal 3, @sable.purse.reload.balance
    assert_equal Date.tomorrow + 7, schedule.reload.next_due_on

    Economy.run_due!(Date.tomorrow + 7)
    assert_equal 2, @wren.purse.reload.balance
    assert @wren.purse.entries.where(kind: "missed").exists?
    assert @sable.purse.entries.where(kind: "missed").exists?
    assert_equal Date.tomorrow + 14, schedule.reload.next_due_on

    # Running again the same day pays nothing twice.
    Economy.run_due!(Date.tomorrow + 7)
    assert_equal 1, @wren.purse.entries.where(kind: "missed").count
  end

  test "payments missed while the economy was off aren't back-paid" do
    give(@wren, 50)
    schedule = Economy::Schedule.create!(from_account: @wren.purse, to_account: @sable.purse, amount: 5, interval: "week", next_due_on: Date.current - 30)
    Economy.run_due!(Date.current)
    assert_equal 50, @wren.purse.reload.balance
    assert schedule.reload.next_due_on > Date.current
  end

  test "the payee can turn a scheduled payment down" do
    schedule = Economy::Schedule.create!(from_account: @wren.purse, to_account: @sable.purse, amount: 5, interval: "week", next_due_on: Date.tomorrow)
    sign_in_as(accounts(:bob))
    delete character_payment_schedule_path(@sable, schedule)
    assert_not schedule.reload.running?
    assert_match "Turned down", schedule.stopped_reason
  end

  test "a retired character's scheduled payments stop" do
    give(@wren, 50)
    schedule = Economy::Schedule.create!(from_account: @wren.purse, to_account: @sable.purse, amount: 5, interval: "week", next_due_on: Date.current)
    @sable.update!(retired_at: Time.current)
    Economy.run_due!
    assert_not schedule.reload.running?
    assert_equal 50, @wren.purse.reload.balance
  end

  test "members can read the bank, bank managers pay from it, and actions are signed" do
    @guild.memberships.create!(character: @wren, bank_manager: true)
    @guild.memberships.create!(character: @sable)
    @guild.bank.credit!(100, kind: "staff", note: "Founding grant")

    get faction_path(@guild)
    assert_select "#bank", count: 0

    sign_in_as(accounts(:bob))
    get faction_path(@guild)
    assert_select ".bank__amount", text: "100 crowns"
    post faction_bank_payments_path(@guild), params: { to: "Sable", amount: 10 }
    assert_equal 100, @guild.bank.reload.balance

    sign_in_as(accounts(:alice))
    post faction_bank_payments_path(@guild), params: { to: "Sable", amount: 10, note: "Wages" }
    assert_equal 90, @guild.bank.reload.balance
    assert_equal @wren, @guild.bank.entries.last.actor_character
  end

  test "only staff make bank managers" do
    membership = @guild.memberships.create!(character: @wren, head: true)
    sign_in_as(accounts(:alice))
    patch faction_membership_path(@guild, membership), params: { faction_membership: { bank_manager: "1" } }
    assert_not membership.reload.bank_manager?

    sign_in_as(accounts(:scribe))
    patch faction_membership_path(@guild, membership), params: { faction_membership: { bank_manager: "1" } }
    assert membership.reload.bank_manager?
  end

  test "a bank pays salaries on a schedule" do
    @guild.memberships.create!(character: @wren, bank_manager: true)
    @guild.bank.credit!(20, kind: "staff")
    sign_in_as(accounts(:alice))
    post faction_bank_schedules_path(@guild), params: { to: "Sable", amount: 5, interval: "fortnight", starts_on: Date.tomorrow }
    Economy.run_due!(Date.tomorrow)
    assert_equal 5, @sable.purse.reload.balance
    assert_equal 15, @guild.bank.reload.balance
    assert_equal Date.tomorrow + 14, Economy::Schedule.last.next_due_on
  end

  test "income tax comes off scheduled income, each faction taking its own share" do
    GameSetting.current.update!(economy_taxes_enabled: true)
    family = Faction.create!(name: "House Corvane", income_tax_percent: 20)
    @guild.update!(income_tax_percent: 10)
    @guild.memberships.create!(character: @sable)
    family.memberships.create!(character: @sable)

    @sable.purse.credit!(100, kind: "allowance", key: "test", taxable: true)
    assert_equal 70, @sable.purse.reload.balance
    assert_equal 10, @guild.bank.reload.balance
    assert_equal 20, family.bank.reload.balance

    # One-off payments aren't taxed.
    give(@wren, 10)
    Economy.transfer!(from: @wren.purse, to: @sable.purse, amount: 10, kind: "payment")
    assert_equal 80, @sable.purse.reload.balance
  end

  test "taxes can't go over the staff limit" do
    GameSetting.current.update!(economy_taxes_enabled: true, economy_tax_max_percent: 15)
    @guild.memberships.create!(character: @wren, bank_manager: true)
    sign_in_as(accounts(:alice))
    patch faction_bank_path(@guild), params: { faction: { income_tax_percent: 30, dues_amount: 0, dues_interval: "month" } }
    assert_equal 0, @guild.reload.income_tax_percent
    patch faction_bank_path(@guild), params: { faction: { income_tax_percent: 15, dues_amount: 2, dues_interval: "week", dues_next_on: Date.tomorrow } }
    assert_equal 15, @guild.reload.income_tax_percent
    assert_equal Date.tomorrow, @guild.dues_next_on
  end

  test "dues are collected, and a member who can't pay is noted, not put in debt" do
    GameSetting.current.update!(economy_taxes_enabled: true)
    @guild.update!(dues_amount: 3, dues_interval: "month", dues_next_on: Date.current)
    @guild.memberships.create!(character: @wren)
    @guild.memberships.create!(character: @sable)
    give(@wren, 5)
    Economy.run_due!
    assert_equal 2, @wren.purse.reload.balance
    assert_equal 0, @sable.purse.reload.balance
    assert_equal 3, @guild.bank.reload.balance
    assert @guild.bank.entries.where(kind: "missed").exists?
    assert_equal Date.current.next_month, @guild.reload.dues_next_on
  end

  test "the weekly allowance goes to approved characters being played, changed by wealth boons" do
    GameSetting.current.update!(economy_allowance: 10)
    wealthy = Soul::Bnb.create!(kind: "boon", name: "Wealthy")
    Economy::AllowanceChange.create!(soul_bnb_id: wealthy.id, amount: 15)
    @wren.character_bnbs.create!(bnb: wealthy, level: "minor", source: "staff")
    characters(:moth).update!(retired_at: Time.current)

    Economy.pay_allowances!
    Economy.pay_allowances!
    assert_equal 25, @wren.purse.reload.balance
    assert_equal 10, @sable.purse.reload.balance
    assert_nil characters(:moth).economy_account
  end

  test "a newly approved character gets the starting amount once" do
    GameSetting.current.update!(economy_starting_amount: 40)
    quill = accounts(:alice).characters.create!(name: "Quill", room: rooms(:commons), status: "submitted")
    quill.approve!(by: accounts(:scribe))
    assert_equal 40, quill.purse.reload.balance
    quill.update!(status: "returned")
    quill.update!(status: "approved")
    assert_equal 40, quill.purse.reload.balance
  end

  test "staff give and take money with a reason, and players can't" do
    sign_in_as(accounts(:alice))
    post admin_economy_adjustments_path, params: { to: "Wren", amount: 5, reason: "Prize" }
    assert_equal 0, @wren.purse.reload.balance

    sign_in_as(accounts(:scribe))
    post admin_economy_adjustments_path, params: { to: "Wren", amount: 5, reason: "" }
    assert_equal 0, @wren.purse.reload.balance
    post admin_economy_adjustments_path, params: { to: "Wren", amount: 5, reason: "Won the tourney" }
    assert_equal 5, @wren.purse.reload.balance
    post admin_economy_adjustments_path, params: { to: "Weavers' Guild", amount: 50, reason: "Grant" }
    assert_equal 50, @guild.bank.reload.balance
    post admin_economy_adjustments_path, params: { to: "Wren", amount: 9, reason: "Fine", direction: "take" }
    assert_equal 5, @wren.purse.reload.balance
    post admin_economy_adjustments_path, params: { to: "Wren", amount: 2, reason: "Fine", direction: "take" }
    assert_equal 3, @wren.purse.reload.balance

    get admin_economy_path
    assert_response :success
    assert_select ".ledger--all .ledger__row", 3
  end

  test "game payments make money on a schedule" do
    sign_in_as(accounts(:scribe))
    post admin_economy_schedules_path, params: { to: "Weavers' Guild", amount: 25, interval: "month", starts_on: Date.tomorrow }
    Economy.run_due!(Date.tomorrow)
    assert_equal 25, @guild.bank.reload.balance
  end

  test "only wellkeepers change the economy's settings" do
    sign_in_as(accounts(:scribe))
    patch admin_economy_path, params: { game_setting: { currency_one: "mark", currency_other: "marks" } }
    assert_equal "crown", GameSetting.current.reload.currency_one

    sign_in_as(accounts(:wellkeeper))
    patch admin_economy_path, params: { game_setting: { currency_one: "mark", currency_other: "marks", currency_symbol: "" } }
    assert_equal "mark", GameSetting.current.reload.currency_one
    assert_equal "1 mark", Economy.money(1)
    GameSetting.current.update!(currency_symbol: "£")
    assert_equal "£1,200", Economy.money(1200)
  end

  test "an inkling can reward money" do
    sign_in_as(accounts(:alice))
    post inklings_path, params: { inkling: { character_id: @wren.id, kind: "goal", title: "Learn to sail", body: "Wren wants a boat." } }
    inkling = Inkling.last
    post inkling_submission_path(inkling)
    sign_in_as(accounts(:scribe))
    post inkling_rewards_path(inkling), params: { reward_type: "money", amount: 12 }
    assert_equal 12, @wren.purse.reload.balance
    assert_equal "inkling", @wren.purse.entries.last.kind
  end
end
