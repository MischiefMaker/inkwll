require "test_helper"

class CraftingTest < ActionDispatch::IntegrationTest
  # Alice plays Wren and Moth, Bob plays Sable, Scribe plays Lark. Wren and
  # Sable stand in the Commons; Moth is in the Hall.
  setup do
    GameSetting.current.update!(economy_enabled: true, crafting_enabled: true)
    @wren = characters(:wren)
    @sable = characters(:sable)
    @sword = Crafting::ItemType.create!(name: "Sword", base_cost: 40, skill: soul_skills(:strength))
    @balanced = Crafting::Feature.create!(name: "Well-balanced", level: "minor", skill_ids: [ soul_skills(:strength).id ])
  end

  def give(character, amount)
    character.purse.credit!(amount, kind: "staff", note: "Test money")
  end

  def item_for(character, name = "Lantern", **attributes)
    character.items.create!(name: name, **attributes)
  end

  # Makes the dice land so the result beats (or misses) the difficulty by `margin`.
  def with_margin(character, skill, difficulty_name, margin)
    total = Soul::Rules.difficulties.fetch(difficulty_name) - character.roll_base(skill) + margin
    original = Soul::Dice.method(:roll)
    Soul::Dice.define_singleton_method(:roll) { |*_args, **_options| { total: total, mode: "normal", segments: [ [ total / 2, total - total / 2 ] ] } }
    yield
  ensure
    Soul::Dice.define_singleton_method(:roll, original)
  end

  def craft(params = {})
    post character_crafts_path(@wren), params: { item_type_id: @sword.id, name: "Thorn", description: "A thin blade.", feature_ids: [ @balanced.id ] }.merge(params)
  end

  test "items need the economy, and crafting and the market need crafting" do
    GameSetting.current.update!(economy_enabled: false)
    get character_path(@wren, tab: "belongings")
    assert_select ".belongings", count: 0
    get market_path
    assert_response :not_found

    GameSetting.current.update!(economy_enabled: true, crafting_enabled: false)
    item_for(@wren)
    get character_path(@wren, tab: "belongings")
    assert_select ".belongings__name", text: "Lantern"
    get market_path
    assert_response :not_found
    sign_in_as(accounts(:alice))
    get new_character_craft_path(@wren)
    assert_response :not_found
  end

  test "everyone can see a character's belongings" do
    item_for(@wren, "Silver locket", description: "Engraved with a heron.")
    get character_path(@wren, tab: "belongings")
    assert_select ".belongings__name", text: "Silver locket"
    assert_select ".belongings__give", count: 0
    get item_path(@wren.items.first)
    assert_select ".item__description", text: /heron/
  end

  test "giving part of a stack splits it and can show in a chapter" do
    arrows = item_for(@wren, "Arrow", quantity: 12)
    sign_in_as(accounts(:alice))
    assert_difference -> { scenes(:duel).poses.roll.count } do
      post character_item_gifts_path(@wren), params: { item_id: arrows.id, quantity: 5, to: "sable", scene_id: scenes(:duel).id }
    end
    assert_equal 7, arrows.reload.quantity
    assert_equal 5, @sable.items.find_by!(name: "Arrow").quantity
    assert_match "Wren gives Sable 5 × Arrow.", scenes(:duel).poses.roll.last.body
    assert Alert.exists?(account: accounts(:bob), kind: "item")

    post character_item_gifts_path(@sable), params: { item_id: @sable.items.first.id, to: "Wren" }
    assert_response :not_found
  end

  test "a trade only goes through once both agree to the same offer" do
    locket = item_for(@wren, "Locket")
    give(@sable, 30)
    sign_in_as(accounts(:alice))
    post character_trades_path(@wren), params: { to: "Sable" }
    trade = Crafting::Trade.last
    assert_redirected_to trade_path(trade)
    patch trade_path(trade), params: { character_id: @wren.id, money: 0, items: { locket.id => 1 } }
    post agree_trade_path(trade), params: { character_id: @wren.id }
    assert trade.reload.from_agreed

    sign_in_as(accounts(:bob))
    patch trade_path(trade), params: { character_id: @sable.id, money: 25 }
    assert_not trade.reload.from_agreed, "changing an offer clears both ticks"
    post agree_trade_path(trade), params: { character_id: @sable.id }
    assert trade.reload.open?

    sign_in_as(accounts(:alice))
    post agree_trade_path(trade), params: { character_id: @wren.id }
    assert trade.reload.done?
    assert_equal @sable, locket.reload.character
    assert_equal 25, @wren.purse.reload.balance
    assert_equal 5, @sable.purse.reload.balance
  end

  test "only the two players in a trade can change it, and staff can look" do
    trade = Crafting::Trade.create!(from_character: @wren, to_character: @sable)
    sign_in_as(accounts(:builder))
    get trade_path(trade)
    assert_response :not_found
    patch trade_path(trade), params: { money: 5 }
    assert_equal 0, trade.reload.from_money

    sign_in_as(accounts(:scribe))
    get trade_path(trade)
    assert_response :success
  end

  test "a trade fails cleanly if someone can't pay" do
    trade = Crafting::Trade.create!(from_character: @wren, to_character: @sable)
    trade.offer!(@wren, money: 50, items: {})
    trade.agree!(@sable)
    assert_raises(Economy::Error) { trade.agree!(@wren) }
    assert trade.reload.open?
  end

  test "a character standing in a place buys from its shop" do
    lantern = Crafting::CatalogueItem.create!(name: "Lantern", price: 8, room_ids: [ rooms(:commons).id ])
    give(@wren, 10)
    sign_in_as(accounts(:alice))
    get room_path(rooms(:commons))
    assert_select ".shop__name", text: "Lantern"
    post room_shop_purchases_path(rooms(:commons)), params: { catalogue_item_id: lantern.id, character_id: @wren.id }
    assert_equal 2, @wren.purse.reload.balance
    assert_equal "Lantern", @wren.items.last.name

    give(characters(:moth), 10)
    post room_shop_purchases_path(rooms(:commons)), params: { catalogue_item_id: lantern.id, character_id: characters(:moth).id }
    assert_match "has to be here", flash[:alert]
    assert_equal 10, characters(:moth).purse.reload.balance
  end

  test "crafting pays the cost and makes the item with the maker's mark" do
    give(@wren, 300)
    sign_in_as(accounts(:alice))
    with_margin(@wren, soul_skills(:strength), "difficult", 2) { craft }
    item = @wren.items.find_by!(name: "Thorn")
    assert_redirected_to item_path(item)
    assert_equal 300 - 40 - 200, @wren.purse.reload.balance
    assert_equal [ @balanced.id ], item.feature_ids
    assert_equal "Wren", item.maker_name
    assert_not item.masterwork?
  end

  test "an exceptional success is a masterwork and gives back half the features' cost" do
    give(@wren, 300)
    sign_in_as(accounts(:alice))
    with_margin(@wren, soul_skills(:strength), "difficult", 12) { craft }
    assert @wren.items.find_by!(name: "Thorn").masterwork?
    assert_equal 300 - 240 + 100, @wren.purse.reload.balance
  end

  test "a complicated success adds a flaw that always counts as a bane" do
    give(@wren, 300)
    sign_in_as(accounts(:alice))
    with_margin(@wren, soul_skills(:strength), "difficult", -2) { craft }
    item = @wren.items.find_by!(name: "Thorn")
    assert_equal "Flawed", item.flaw_name
    flaw = @wren.roll_extras.find(&:always?)
    assert_equal "bane", flaw.kind
    roll = @wren.roll_skill(soul_skills(:strength), "standard", extras: [])
    assert roll.applied.any? { |entry| entry["name"].start_with?("Flawed") }
  end

  test "failing loses half the cost, and a catastrophic failure all of it" do
    give(@wren, 480)
    sign_in_as(accounts(:alice))
    with_margin(@wren, soul_skills(:strength), "difficult", -15) { craft }
    assert_not @wren.items.exists?
    assert_equal 480 - 120, @wren.purse.reload.balance

    with_margin(@wren, soul_skills(:strength), "difficult", -40) { craft }
    assert_equal 480 - 120 - 240, @wren.purse.reload.balance
  end

  test "crafting checks the money, the feature limit and what fits" do
    sign_in_as(accounts(:alice))
    craft
    assert_match "only has", flash[:alert]

    give(@wren, 5000)
    GameSetting.current.update!(crafting_max_features: 1)
    pocket = Crafting::Feature.create!(name: "Concealed pocket", level: "minor", skill_ids: [ soul_skills(:wit).id ])
    craft(feature_ids: [ @balanced.id, pocket.id ])
    assert_match "more than 1 features", flash[:alert]

    dress = Crafting::ItemType.create!(name: "Dress", base_cost: 25)
    @balanced.update!(item_type_ids: [ @sword.id ])
    craft(item_type_id: dress.id)
    assert_match "doesn't fit", flash[:alert]
    assert_equal 5000, @wren.purse.reload.balance
  end

  test "without SOUL, crafting always succeeds" do
    GameSetting.current.update!(soul_enabled: false)
    give(@wren, 240)
    sign_in_as(accounts(:alice))
    craft
    assert @wren.items.exists?(name: "Thorn")
    assert_equal 0, @wren.purse.reload.balance
  end

  test "item features show in the roll box and count when ticked" do
    item = item_for(@wren, "Thorn", feature_ids: [ @balanced.id ])
    sign_in_as(accounts(:alice))
    get scene_path(scenes(:duel))
    assert_select ".roll-box__extra", text: /Well-balanced \(Thorn\)/
    post scene_rolls_path(scenes(:duel)), params: { confirmed: "1", skill_id: soul_skills(:strength).id, difficulty: "standard", extra_keys: [ "item-#{item.id}-#{@balanced.id}" ] }
    assert_match "Well-balanced (Thorn) (Minor Boon, +1)", scenes(:duel).poses.roll.last.body

    GameSetting.current.update!(crafting_enabled: false)
    assert_empty @wren.roll_extras
  end

  test "the storyteller can rule on an item feature" do
    item = item_for(@wren, "Thorn", feature_ids: [ @balanced.id ])
    scene = scenes(:duel)
    scene.participant_for(@sable).update_column(:role, "storyteller")
    sign_in_as(accounts(:bob))
    post scene_pending_rolls_path(scene), params: { character_id: @wren.id, skill_id: soul_skills(:strength).id, difficulty: "standard",
      extra_rulings: { "item-#{item.id}-#{@balanced.id}" => "must" } }
    assert_match "Well-balanced (Thorn)", scene.poses.roll.last.body
  end

  test "items sell on the market, and the sale is taxable income" do
    GameSetting.current.update!(factions_enabled: true, economy_taxes_enabled: true)
    guild = Faction.create!(name: "Smiths", income_tax_percent: 10)
    guild.memberships.create!(character: @wren)
    blade = item_for(@wren, "Thorn")
    sign_in_as(accounts(:alice))
    post item_listing_path(blade), params: { price: 50 }
    assert blade.reload.for_sale?

    get market_path
    assert_select ".market__name", text: "Thorn"
    give(@sable, 60)
    sign_in_as(accounts(:bob))
    post item_purchase_path(blade), params: { character_id: @sable.id }
    assert_equal @sable, blade.reload.character
    assert_not blade.for_sale?
    assert_equal 10, @sable.purse.reload.balance
    assert_equal 45, @wren.purse.reload.balance
    assert_equal 5, guild.bank.reload.balance
  end

  test "players can't list or buy for others" do
    blade = item_for(@wren, "Thorn")
    sign_in_as(accounts(:bob))
    post item_listing_path(blade), params: { price: 5 }
    assert_response :not_found
    blade.update!(price: 5, listed_at: Time.current)
    give(@wren, 10)
    post item_purchase_path(blade), params: { character_id: @wren.id }
    assert_equal @wren, blade.reload.character
  end

  test "players propose features and staff approve them" do
    sign_in_as(accounts(:alice))
    post character_feature_proposals_path(@wren), params: { feature: { name: "Hidden blade", level: "major", skill_ids: [ soul_skills(:wit).id ] } }
    proposal = Crafting::Feature.find_by!(name: "Hidden blade")
    assert proposal.proposed?
    patch admin_crafting_feature_path(proposal), params: { decision: "approve" }
    assert proposal.reload.proposed?

    sign_in_as(accounts(:scribe))
    get admin_crafting_path
    assert_select ".crafting-admin__proposal", text: /Hidden blade/
    patch admin_crafting_feature_path(proposal), params: { decision: "approve" }
    assert proposal.reload.approved?
    assert Alert.exists?(account: accounts(:alice), kind: "item")
  end

  test "staff run the catalogue and give and take items with a reason" do
    sign_in_as(accounts(:bob))
    get admin_catalogue_items_path
    assert_response :redirect
    post admin_items_path, params: { to: "Sable", name: "Gold bar", reason: "Mine" }
    assert_not @sable.items.exists?

    sign_in_as(accounts(:scribe))
    post admin_catalogue_items_path, params: { crafting_catalogue_item: { name: "Rope", price: 2, room_ids: [ "", rooms(:hall).id ] } }
    rope = Crafting::CatalogueItem.find_by!(name: "Rope")
    assert_equal [ rooms(:hall) ], rope.rooms.to_a
    post admin_items_path, params: { to: "Sable", catalogue_item_id: rope.id, quantity: 3, reason: "Found in the cellar" }
    item = @sable.items.find_by!(name: "Rope")
    assert_equal 3, item.quantity
    delete admin_item_path(item), params: { reason: "" }
    assert Crafting::Item.exists?(item.id)
    delete admin_item_path(item), params: { reason: "Lost at sea" }
    assert_not Crafting::Item.exists?(item.id)
    assert_equal "Lost at sea", Crafting::ItemEvent.find_by!(kind: "staff_take").note
  end

  test "an inkling can reward an item from the catalogue" do
    rope = Crafting::CatalogueItem.create!(name: "Rope", price: 2)
    sign_in_as(accounts(:alice))
    post inklings_path, params: { inkling: { character_id: @wren.id, kind: "goal", title: "Climb", body: "Up the tower." } }
    inkling = Inkling.last
    post inkling_submission_path(inkling)
    sign_in_as(accounts(:scribe))
    get inkling_path(inkling)
    assert_select "option[value=item]"
    post inkling_rewards_path(inkling), params: { reward_type: "item", catalogue_item_id: rope.id, amount: 2 }
    assert_equal 2, @wren.items.find_by!(name: "Rope").quantity
    assert_equal "reward", Crafting::ItemEvent.last.kind
  end

  test "the crafting pages open" do
    item = item_for(@wren, "Thorn", feature_ids: [ @balanced.id ], flaw_name: "Chipped", maker: @wren, maker_name: "Wren", made_at: Time.current)
    Crafting::Trade.create!(from_character: @wren, to_character: @sable)
    sign_in_as(accounts(:alice))
    get new_character_craft_path(@wren)
    assert_select ".craft__feature", text: /Well-balanced/
    get item_path(item)
    assert_select ".item__flaw-form"
    assert_select ".item__maker", text: /Made by/
    get character_path(@wren, tab: "belongings")
    assert_select ".belongings__give-form"
    assert_select ".belongings__trade-link"
    get trades_path
    assert_select ".trades__item"

    sign_in_as(accounts(:wellkeeper))
    get admin_crafting_path
    assert_select ".crafting-admin__settings-form"
    get admin_catalogue_items_path
    assert_response :success
    get edit_admin_item_path(item)
    assert_response :success
    get edit_admin_crafting_feature_path(@balanced)
    assert_response :success
    get edit_admin_crafting_item_type_path(@sword)
    assert_response :success
    get edit_admin_features_path
    assert_select "#game_setting_crafting_enabled"
  end

  test "players are turned away from other people's items, crafting and the staff pages" do
    blade = item_for(@wren, "Thorn", flaw_name: "Chipped")
    give(@wren, 300)
    trade = Crafting::Trade.create!(from_character: @wren, to_character: characters(:moth))
    sign_in_as(accounts(:bob))
    post character_crafts_path(@wren), params: { item_type_id: @sword.id, name: "Stolen" }
    assert_response :not_found
    post character_feature_proposals_path(@wren), params: { feature: { name: "Sneaky", level: "minor" } }
    assert_response :not_found
    patch item_path(blade), params: { item: { flaw_name: "Ruined" } }
    assert_response :not_found
    delete trade_path(trade)
    assert trade.reload.open?
    post admin_crafting_item_types_path, params: { crafting_item_type: { name: "Gold" } }
    patch admin_crafting_path, params: { game_setting: { crafting_minor_cost: 0 } }
    post admin_crafting_features_path, params: { crafting_feature: { name: "Cheat", level: "legendary", skill_ids: [ soul_skills(:wit).id ] } }
    assert_not Crafting::ItemType.exists?(name: "Gold")
    assert_not Crafting::Feature.exists?(name: "Cheat")
    assert_equal 200, GameSetting.current.reload.crafting_minor_cost
    assert_equal "Chipped", blade.reload.flaw_name
    assert_equal 300, @wren.purse.reload.balance

    sign_in_as(accounts(:scribe))
    patch admin_crafting_path, params: { game_setting: { crafting_minor_cost: 0 } }
    assert_equal 200, GameSetting.current.reload.crafting_minor_cost, "only Wellkeepers change the costs"
  end
end
