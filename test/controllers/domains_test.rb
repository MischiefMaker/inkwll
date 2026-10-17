require "test_helper"

class DomainsTest < ActionDispatch::IntegrationTest
  # Alice plays Wren, Bob plays Sable. Sable holds the Duchy; Wren holds a
  # County under it, which holds a Barony nobody holds.
  setup do
    GameSetting.current.update!(economy_enabled: true, domains_enabled: true, factions_enabled: true)
    @wren = characters(:wren)
    @sable = characters(:sable)
    @duchy = Domain.create!(name: "Niwen", rank: "Duchy", holder_character: @sable, people: 100, yield_per_head: 2)
    @county = Domain.create!(name: "Aqagia", rank: "County", liege: @duchy, holder_character: @wren, people: 50, yield_per_head: 2, tax_percent: 10)
    @barony = Domain.create!(name: "Everean", rank: "Barony", liege: @county, people: 100, yield_per_head: 1, tax_percent: 20)
  end

  test "domains stay hidden until switched on, and need the economy" do
    GameSetting.current.update!(economy_enabled: false)
    get domains_path
    assert_response :not_found
  end

  test "anyone can see the tree, but only holders, their liege and staff see the money" do
    get domains_path
    assert_response :success
    assert_select ".domain__name", text: "Everean"
    assert_select ".domain__holder", text: /held by\s+Sable/
    assert_select ".domain__sums", count: 0

    sign_in_as(accounts(:alice))
    get domains_path
    # Wren sees Aqagia (hers) and Everean (her vassal), not the Duchy.
    assert_select "#domain-#{@county.id} > .domain__sums", text: /20 crowns from vassals/
    assert_select "#domain-#{@barony.id} > .domain__sums"
    assert_select "#domain-#{@duchy.id} > .domain__sums", count: 0

    sign_in_as(accounts(:scribe))
    get domains_path
    assert_select ".domain__sums", count: 3
  end

  test "the month's money flows up the chain and each holder keeps the rest" do
    Domain.pay_month!(Date.new(2026, 11, 1))
    # Everean earns 100, pays 20 to Aqagia; nobody holds it, so the other 80 goes nowhere.
    # Aqagia earns 100 + 20 = 120, pays 12 to Niwen, keeps 108.
    # Niwen earns 200 + 12 = 212.
    assert_equal 108, @wren.purse.reload.balance
    assert_equal 212, @sable.purse.reload.balance
    tax = @sable.purse.entries.find_by(kind: "domain_tax")
    assert_equal 12, tax.amount
    assert_equal "Wren", tax.counterparty.owner_name

    # Paying the same month again does nothing.
    Domain.pay_month!(Date.new(2026, 11, 2))
    assert_equal 108, @wren.purse.reload.balance
    assert_equal 212, @sable.purse.reload.balance
  end

  test "a faction can hold a domain, and its share goes to the bank" do
    clan = Faction.create!(name: "Clan Odde")
    @barony.update!(holder_faction: clan)
    Domain.pay_month!(Date.new(2026, 11, 1))
    assert_equal 80, clan.bank.reload.balance
    assert_equal 108, @wren.purse.reload.balance
  end

  test "a domain can't be its own liege, even round a loop" do
    @duchy.liege = @barony
    assert_not @duchy.valid?
    assert @duchy.errors[:liege].any?
  end

  test "a liege's holder sets their vassal's tax, within the limit" do
    sign_in_as(accounts(:alice))
    patch domain_path(@barony), params: { domain: { tax_percent: 30 } }
    assert_equal 30, @barony.reload.tax_percent

    patch domain_path(@barony), params: { domain: { tax_percent: 80 } }
    assert_equal 30, @barony.reload.tax_percent
    assert_match "at most 50%", flash[:alert]
  end

  test "nobody else can set a domain's tax" do
    sign_in_as(accounts(:alice))
    patch domain_path(@county), params: { domain: { tax_percent: 0 } }
    assert_equal 10, @county.reload.tax_percent
    assert_match "Only the holder", flash[:alert]

    sign_in_as(accounts(:bob))
    patch domain_path(@barony), params: { domain: { tax_percent: 0 } }
    assert_equal 20, @barony.reload.tax_percent
  end

  test "only wellkeepers make and change domains" do
    sign_in_as(accounts(:scribe))
    get admin_domains_path
    assert_redirected_to root_path
    post admin_domains_path, params: { domain: { name: "Sneaky" } }
    assert_not Domain.exists?(name: "Sneaky")

    sign_in_as(accounts(:wellkeeper))
    get admin_domains_path
    assert_response :success
    post admin_domains_path, params: { domain: { name: "Faraway", rank: "Barony", liege_id: @county.id, holder_name: "sable", people: 10, yield_per_head: 3, tax_percent: 5 } }
    assert_redirected_to admin_domains_path
    faraway = Domain.find_by!(name: "Faraway")
    assert_equal @sable, faraway.holder_character

    patch admin_domain_path(faraway), params: { domain: { holder_name: "Nobody Real" } }
    assert_response :unprocessable_entity
    patch admin_domain_path(faraway), params: { domain: { people: 20, holder_name: "" } }
    assert_nil faraway.reload.holder_character
    assert_equal 20, faraway.people
  end

  test "an area linked to a domain says whose land it is" do
    @duchy.update!(area: areas(:castle))
    get area_path(areas(:castle))
    assert_select ".area-domain", text: /Niwen \(Duchy\), held by Sable/
  end
end
