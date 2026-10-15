require "test_helper"

class JcinkAddOnsTest < ActionDispatch::IntegrationTest
  setup do
    accounts(:alice).update!(active_character: characters(:wren))
    accounts(:bob).update!(active_character: characters(:sable))
  end

  # --- Alerts --------------------------------------------------------------

  test "a new Passage alerts the others in the Chapter, one alert per Chapter" do
    sign_in_as(accounts(:alice))
    post scene_poses_path(scenes(:duel)), params: { pose: { body: "Wren lunges." } }

    alert = accounts(:bob).alerts.unread.find_by(kind: "passage")
    assert_equal scenes(:duel), alert.scene
    assert_equal 1, alert.count
    assert_empty accounts(:alice).alerts.where(kind: "passage")

    Alert.notify!(accounts(:bob), "passage", scene: scenes(:duel))
    assert_equal 2, alert.reload.count
    assert_equal 1, accounts(:bob).alerts.unread.where(kind: "passage").count
  end

  test "an @mention alerts the mentioned character's player" do
    sign_in_as(accounts(:alice))
    post scene_poses_path(scenes(:duel)), params: { pose: { body: "Wren glances at @Sable." } }
    assert accounts(:bob).alerts.exists?(kind: "mention", character: characters(:sable))
  end

  test "finishing a Chapter alerts the other players" do
    scenes(:duel).finish!(by: characters(:wren))
    assert accounts(:bob).alerts.exists?(kind: "finished", scene: scenes(:duel))
    assert_not accounts(:alice).alerts.exists?(kind: "finished")
  end

  test "the bell shows unread alerts, and opening the list reads them" do
    Alert.notify!(accounts(:bob), "turn", scene: scenes(:duel), character: characters(:sable))
    sign_in_as(accounts(:bob))

    get root_path
    assert_select "#alert_count .alert-bell__number", text: "1"

    assert_select "details.alert-menu turbo-frame#alerts_panel[data-src=?]", alerts_path

    # The drop-down loads the list on its own, without the page around it.
    get alerts_path, headers: { "Turbo-Frame" => "alerts_panel" }
    assert_select ".site-header", count: 0
    assert_select "turbo-frame#alerts_panel .alerts__item--turn", text: /Sable's turn/
    assert_equal 0, accounts(:bob).alerts.unread.count
  end

  test "opening a Chapter reads its alerts" do
    Alert.notify!(accounts(:bob), "passage", scene: scenes(:duel))
    sign_in_as(accounts(:bob))
    get scene_path(scenes(:duel))
    assert_equal 0, accounts(:bob).alerts.unread.count
  end

  test "players only see their own alerts" do
    Alert.notify!(accounts(:bob), "passage", scene: scenes(:duel))
    sign_in_as(accounts(:alice))
    get alerts_path
    assert_select ".alerts__item", count: 0
    assert_equal 1, accounts(:bob).alerts.unread.count
  end

  test "old read alerts are cleaned up" do
    old = Alert.create!(account: accounts(:bob), kind: "finished", read_at: 40.days.ago)
    fresh = Alert.create!(account: accounts(:bob), kind: "finished")
    AlertCleanupJob.perform_now
    assert_not Alert.exists?(old.id)
    assert Alert.exists?(fresh.id)
  end

  # --- My Chapters ----------------------------------------------------------

  test "My Chapters lists each character's open Chapters and whose turn it is" do
    sign_in_as(accounts(:alice))
    get my_chapters_path
    assert_select ".chapter-tracker__name", text: "Wren"
    assert_select ".chapter-tracker__name", text: "Moth"
    assert_select ".chapter-tracker__row--my-turn .chapter-tracker__title", text: scenes(:duel).title
    assert_select ".chapter-tracker__title", text: scenes(:secret).title, count: 0
  end

  # --- Subtitles and labels -------------------------------------------------

  test "a Chapter gets a subtitle and labels staff defined" do
    warning = SceneLabel.create!(name: "Violence")
    sign_in_as(accounts(:alice))
    post scenes_path, params: { scene: { title: "Market Day", subtitle: "Haggling over apples", visibility: "joinable", pose_mode: "free", label_ids: [ "", warning.id.to_s, "99999" ] } }
    scene = Scene.last
    assert_equal "Haggling over apples", scene.subtitle
    assert_equal [ warning.id ], scene.label_ids

    get room_path(rooms(:commons))
    assert_select ".scene-list__subtitle", text: "Haggling over apples"
    assert_select ".scene-label", text: "Violence"

    warning.destroy
    assert_empty scene.reload.label_ids
  end

  test "only Wellkeepers manage Chapter labels and character groups" do
    sign_in_as(accounts(:scribe))
    post admin_scene_labels_path, params: { scene_label: { name: "Gore" } }
    assert_redirected_to root_path
    post admin_character_groups_path, params: { character_group: { name: "Ravens", colour: "#336699" } }
    assert_redirected_to root_path
    assert_equal 0, SceneLabel.count + CharacterGroup.count

    sign_in_as(accounts(:wellkeeper))
    post admin_scene_labels_path, params: { scene_label: { name: "Gore" } }
    post admin_character_groups_path, params: { character_group: { name: "Ravens", colour: "#336699" } }
    assert_equal 1, SceneLabel.count
    assert_equal 1, CharacterGroup.count
  end

  # --- Groups and Passage details ------------------------------------------

  test "a group colours the character's name and shows beside their Passages" do
    ravens = CharacterGroup.create!(name: "Ravens", colour: "#336699")
    characters(:wren).update!(character_group: ravens)
    profile_fields(:hometown).update!(on_passages: true)
    characters(:wren).profile_values.create!(profile_field: profile_fields(:hometown), value: "Ravenhollow")
    scenes(:duel).post!(characters(:wren), "Wren bows.")

    sign_in_as(accounts(:bob))
    get scene_path(scenes(:duel))
    assert_select ".pose__name.character-name--grouped[style*='#336699']", text: "Wren"
    assert_select ".pose__details", text: /Ravens · Hometown: Ravenhollow/
  end

  test "a player picks a group before approval, but not after" do
    ravens = CharacterGroup.create!(name: "Ravens", colour: "#336699")
    GameSetting.current.update!(approval_required: true)
    sign_in_as(accounts(:alice))

    patch character_path(characters(:wren)), params: { character: { character_group_id: ravens.id } }
    assert_nil characters(:wren).reload.character_group

    characters(:wren).update!(status: "draft")
    patch character_path(characters(:wren)), params: { character: { character_group_id: ravens.id } }
    assert_equal ravens, characters(:wren).reload.character_group
  end

  test "staff change a character's group, players can't" do
    ravens = CharacterGroup.create!(name: "Ravens", colour: "#336699")
    sign_in_as(accounts(:alice))
    patch admin_character_path(characters(:sable)), params: { character: { character_group_id: ravens.id } }
    assert_nil characters(:sable).reload.character_group

    sign_in_as(accounts(:wellkeeper))
    patch admin_character_path(characters(:sable)), params: { character: { character_group_id: ravens.id } }
    assert_equal ravens, characters(:sable).reload.character_group
  end

  test "the directory filters by group" do
    ravens = CharacterGroup.create!(name: "Ravens", colour: "#336699")
    characters(:wren).update!(character_group: ravens)
    sign_in_as(accounts(:bob))
    get directory_path, params: { group: ravens.id }
    assert_select ".directory__name", text: "Wren"
    assert_select ".directory__name", text: "Sable", count: 0
  end

  test "the directory has a tab per group, a Roster tab, and an Unapproved tab only staff see" do
    CharacterGroup.create!(name: "Ravens", colour: "#336699")
    draft = accounts(:bob).characters.create!(name: "Newcomer")
    draft.update_columns(status: "submitted")

    sign_in_as(accounts(:bob))
    get directory_path
    assert_select ".directory-tabs__tab--group", text: "Ravens"
    assert_select ".directory-tabs__tab--roster"
    assert_select ".directory-tabs__tab--unapproved", count: 0
    get directory_path, params: { unapproved: 1 }
    assert_select ".directory__name", text: "Newcomer", count: 0

    sign_in_as(accounts(:scribe))
    get directory_path, params: { unapproved: 1 }
    assert_select ".directory-tabs__tab--unapproved.directory-tabs__tab--current"
    assert_select ".directory__name", text: "Newcomer"
    assert_select ".directory__name", text: "Wren", count: 0
  end

  test "staff see what's waiting on them in the bell, and players don't" do
    character = accounts(:alice).characters.create!(name: "Applicant", status: "draft")
    character.update_columns(status: "submitted", submitted_at: Time.current)

    sign_in_as(accounts(:scribe))
    get root_path
    assert_select "#alert_count .alert-bell__number", text: "1"
    get alerts_path, headers: { "Turbo-Frame" => "alerts_panel" }
    assert_select ".alerts__staff-item--applications", text: /1 Applications/
    assert_select ".alerts__staff-link[href=?]", admin_applications_path

    sign_in_as(accounts(:alice))
    get alerts_path
    assert_select ".alerts__staff", count: 0
    get root_path
    assert_select "#alert_count .alert-bell__number", count: 0
  end
end
