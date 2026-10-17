require "test_helper"

class FactionsTest < ActionDispatch::IntegrationTest
  # Alice plays Wren and Moth, Bob plays Sable, Scribe plays Lark.
  setup do
    GameSetting.current.update!(factions_enabled: true)
    @guild = Faction.create!(name: "Weavers' Guild", description: "Cloth and gossip.")
    @family = Faction.create!(name: "House Corvane", pick_on_application: false)
    @knives = Faction.create!(name: "The Quiet Knives", secret: true)
  end

  test "factions are switched off until a game turns them on" do
    GameSetting.current.update!(factions_enabled: false)
    get factions_path
    assert_response :not_found
    sign_in_as(accounts(:alice))
    get root_path
    assert_select "a[href=?]", factions_path, count: 0
  end

  test "guests see the open factions and their members, never the secret ones" do
    @guild.memberships.create!(character: characters(:wren), title: "Master Weaver")
    get factions_path
    assert_response :success
    assert_select ".factions__name", text: "Weavers' Guild"
    assert_select ".factions__name", text: "The Quiet Knives", count: 0

    get faction_path(@guild)
    assert_select ".faction__member-name", text: "Wren"
    assert_select ".faction__title", text: "Master Weaver"
    get faction_path(@knives)
    assert_response :not_found
  end

  test "a secret faction is seen by its members and staff only" do
    @knives.memberships.create!(character: characters(:sable))
    sign_in_as(accounts(:alice))
    get faction_path(@knives)
    assert_response :not_found

    sign_in_as(accounts(:bob))
    get faction_path(@knives)
    assert_select ".faction__member-name", text: "Sable"

    sign_in_as(accounts(:scribe))
    get factions_path
    assert_select ".factions__name", text: "The Quiet Knives"
  end

  test "a secret membership shows only to its player, the heads and staff" do
    @guild.memberships.create!(character: characters(:sable), secret: true)
    @guild.memberships.create!(character: characters(:moth), head: true)
    get faction_path(@guild)
    assert_select ".faction__member-name", text: "Sable", count: 0

    sign_in_as(accounts(:bob))
    get faction_path(@guild)
    assert_select ".faction__member--secret .faction__member-name", text: "Sable"

    sign_in_as(accounts(:alice))
    get faction_path(@guild)
    assert_select ".faction__member-name", text: "Sable"

    sign_out
    get character_path(characters(:sable))
    assert_select ".character-profile__factions", count: 0
  end

  test "players pick open factions on the application, but not after approval" do
    GameSetting.current.update!(approval_required: true)
    sign_in_as(accounts(:alice))
    post characters_path, params: { character: { name: "Quill", picked_faction_ids: [ "", @guild.id, @family.id, @knives.id ] } }
    quill = Character.find_by!(name: "Quill")
    assert_equal [ @guild ], quill.factions.to_a

    patch character_path(quill), params: { character: { picked_faction_ids: [ "" ] } }
    assert_empty quill.reload.factions

    quill.update!(status: "approved")
    patch character_path(quill), params: { character: { picked_faction_ids: [ "", @guild.id ] } }
    assert_empty quill.reload.factions
  end

  test "unticking on the application keeps memberships heads added in closed factions" do
    GameSetting.current.update!(approval_required: true)
    characters(:moth).update!(status: "draft")
    @family.memberships.create!(character: characters(:moth))
    sign_in_as(accounts(:alice))
    patch character_path(characters(:moth)), params: { character: { picked_faction_ids: [ "" ] } }
    assert_equal [ @family ], characters(:moth).reload.factions.to_a
  end

  test "a head adds members and sets titles, but only staff choose heads" do
    @guild.memberships.create!(character: characters(:wren), head: true)
    sign_in_as(accounts(:alice))
    post faction_memberships_path(@guild), params: { name: "sable", title: "Apprentice" }
    membership = @guild.memberships.find_by!(character: characters(:sable))
    assert_equal "Apprentice", membership.title

    patch faction_membership_path(@guild, membership), params: { faction_membership: { title: "Journeyman", head: "1" } }
    membership.reload
    assert_equal "Journeyman", membership.title
    assert_not membership.head?

    sign_in_as(accounts(:scribe))
    patch faction_membership_path(@guild, membership), params: { faction_membership: { head: "1" } }
    assert membership.reload.head?
  end

  test "a player who isn't a head can't add members" do
    @guild.memberships.create!(character: characters(:sable))
    sign_in_as(accounts(:bob))
    post faction_memberships_path(@guild), params: { name: "Wren" }
    assert_redirected_to faction_path(@guild)
    assert_not @guild.memberships.exists?(character: characters(:wren))
  end

  test "a head can't remove another head, and a player can leave" do
    @guild.memberships.create!(character: characters(:wren), head: true)
    other_head = @guild.memberships.create!(character: characters(:lark), head: true)
    mine = @guild.memberships.create!(character: characters(:sable))

    sign_in_as(accounts(:alice))
    delete faction_membership_path(@guild, other_head)
    assert FactionMembership.exists?(other_head.id)

    sign_in_as(accounts(:bob))
    delete faction_membership_path(@guild, mine)
    assert_not FactionMembership.exists?(mine.id)
  end

  test "the profile lists the factions a viewer may see" do
    @guild.memberships.create!(character: characters(:sable), title: "Dyer")
    @knives.memberships.create!(character: characters(:sable))
    get character_path(characters(:sable))
    assert_select ".character-profile__faction", text: /Weavers' Guild, Dyer/
    assert_select ".character-profile__faction", text: /Quiet Knives/, count: 0

    sign_in_as(accounts(:bob))
    get character_path(characters(:sable))
    assert_select ".character-profile__faction", text: /Quiet Knives/
  end

  test "Wellkeepers make factions; players can't" do
    sign_in_as(accounts(:alice))
    post admin_factions_path, params: { faction: { name: "Lamplighters" } }
    assert_not Faction.exists?(name: "Lamplighters")

    sign_in_as(accounts(:wellkeeper))
    post admin_factions_path, params: { faction: { name: "Lamplighters", secret: "1" } }
    assert Faction.find_by!(name: "Lamplighters").secret?
    get admin_factions_path
    assert_select ".factions-admin a", text: "Lamplighters"
  end

  test "the Features page switches factions on and off" do
    sign_in_as(accounts(:wellkeeper))
    patch admin_features_path, params: { game_setting: { factions_enabled: "0" } }
    assert_not GameSetting.current.reload.factions_enabled?
  end

  test "an Inkling shared with a faction is read and written by its members" do
    @knives.memberships.create!(character: characters(:sable))
    inkling = Inkling.start!(character: characters(:wren), by: accounts(:alice), kind: "goal", title: "A quiet job", body: "Wren needs help.")

    sign_in_as(accounts(:alice))
    post inkling_shares_path(inkling), params: { faction_id: @knives.id }
    assert_response :not_found
    post inkling_shares_path(inkling), params: { faction_id: @guild.id }
    assert_equal [ @guild.id ], inkling.reload.shared_faction_ids

    sign_in_as(accounts(:bob))
    get inkling_path(inkling)
    assert_response :not_found

    inkling.update!(shared_faction_ids: [ @knives.id ])
    get inkling_path(inkling)
    assert_response :success
    post inkling_entries_path(inkling), params: { body: "Sable can help.", kind: "public" }
    assert_equal characters(:sable), inkling.entries.last.character
  end

  test "NPC heads show on the page, and staff are told when they run a faction" do
    @family.update!(npc_heads: "Lady Corvane, Old Tamsin")
    head = @family.memberships.create!(character: characters(:sable), head: true)
    characters(:sable).update!(on_roster_at: Time.current)
    assert_not @family.player_heads?

    get faction_path(@family)
    assert_select ".faction__member--npc .faction__npc-name", text: "Lady Corvane"
    assert_select ".faction__member--npc .faction__npc-name", text: "Old Tamsin"
    assert_select ".faction__staff-run", count: 0

    sign_in_as(accounts(:scribe))
    get faction_path(@family)
    assert_select ".faction__staff-run"
    assert_select ".faction__tag--roster"

    characters(:sable).update!(on_roster_at: nil)
    assert @family.player_heads?
    get faction_path(@family)
    assert_select ".faction__staff-run", count: 0
    assert head.reload.head?
  end
end
