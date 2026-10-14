require "test_helper"

class RosterTest < ActionDispatch::IntegrationTest
  test "a character put on the roster leaves its player and unfinished Chapters" do
    wren = characters(:wren)
    accounts(:alice).update!(active_character: wren)
    wren.put_on_roster!(note: "Looking for someone who likes mysteries.")

    wren.reload
    assert wren.on_roster?
    assert wren.retired?
    assert_not wren.can_play?
    assert_equal Account.roster_keeper, wren.account
    assert_nil accounts(:alice).reload.active_character
    assert wren.scene_participants.includes(:scene).none? { |participant| !participant.scene.finished? }
  end

  test "nobody can log in as the Roster account" do
    keeper = Account.roster_keeper
    assert keeper.system?
    assert_equal keeper, Account.roster_keeper
    assert_nil Account.log_in("the roster", "anything")
  end

  test "a player applies for a roster character and staff approve it" do
    wren = characters(:wren)
    wren.put_on_roster!
    sign_in_as(accounts(:bob))

    get character_path(wren)
    assert_select ".roster-status__apply"
    assert_select "a", text: /Message the player/, count: 0

    post character_roster_applications_path(wren), params: { roster_application: { note: "I'd love to play her." } }
    assert_redirected_to character_path(wren)
    application = RosterApplication.last
    assert application.pending?

    other = RosterApplication.create!(character: wren, account: accounts(:builder), note: "Me too.")

    sign_in_as(accounts(:scribe))
    patch admin_roster_application_path(application), params: { decision: "approve" }
    assert_redirected_to admin_roster_path

    wren.reload
    assert_equal accounts(:bob), wren.account
    assert_not wren.on_roster?
    assert wren.can_play?
    assert other.reload.denied?
  end

  test "you can't apply for a character that isn't on the roster" do
    sign_in_as(accounts(:bob))
    get new_character_roster_application_path(characters(:wren))
    assert_response :not_found
  end

  test "a player who isn't staff can't approve roster applications" do
    wren = characters(:wren)
    wren.put_on_roster!
    application = RosterApplication.create!(character: wren, account: accounts(:bob), note: "Please.")

    sign_in_as(accounts(:bob))
    patch admin_roster_application_path(application), params: { decision: "approve" }
    assert_redirected_to root_path
    assert application.reload.pending?
    get admin_roster_path
    assert_redirected_to root_path
  end

  test "a player asks to put their own character on the roster and staff agree" do
    sign_in_as(accounts(:alice))
    post character_roster_request_path(characters(:wren))
    assert characters(:wren).reload.roster_requested?

    sign_in_as(accounts(:scribe))
    get admin_roster_path
    assert_select ".roster-admin__item--request", text: /Wren/

    patch admin_roster_character_path(characters(:wren)), params: { roster_note: "Ready for a new player." }
    assert characters(:wren).reload.on_roster?
    assert_equal "Ready for a new player.", characters(:wren).roster_note
  end

  test "staff can decline a request to give a character up" do
    characters(:wren).request_roster!
    sign_in_as(accounts(:scribe))
    patch admin_roster_character_path(characters(:wren)), params: { decision: "decline" }
    assert_not characters(:wren).reload.roster_requested?
    assert_equal accounts(:alice), characters(:wren).account
  end

  test "players can't ask to put someone else's character on the roster" do
    sign_in_as(accounts(:bob))
    post character_roster_request_path(characters(:wren))
    assert_response :not_found
    assert_not characters(:wren).reload.roster_requested?
  end

  test "staff add a new character straight to the roster" do
    sign_in_as(accounts(:scribe))
    assert_difference "Character.on_roster.count" do
      post admin_roster_characters_path, params: { character: { name: "The Lost Heir", roster_note: "Wanted!" } }
    end
    assert Character.find_by(name: "The Lost Heir").approved?
  end

  test "the new player of a staff-made roster character finishes the sheet" do
    GameSetting.current.update!(approval_required: true)
    heir = Character.create_for_roster!(name: "The Lost Heir")
    RosterApplication.create!(character: heir, account: accounts(:bob), note: "Me!").approve!(by: accounts(:scribe))
    assert heir.reload.sheet_open?

    sign_in_as(accounts(:bob))
    post character_sheet_lock_path(heir)
    assert_not heir.reload.sheet_open?
  end

  test "characters whose players chose it go back on the roster when idle" do
    wren, moth = characters(:wren), characters(:moth)
    wren.update_columns(roster_when_idle: true, last_active_at: 100.days.ago)
    moth.update_columns(last_active_at: 100.days.ago)

    RosterIdleJob.perform_now

    assert wren.reload.on_roster?
    assert_not moth.reload.on_roster?
  end

  test "the directory lists characters and filters by a public field" do
    hometown = profile_fields(:hometown)
    characters(:wren).profile_values.create!(profile_field: hometown, value: "Ravenhollow")
    characters(:moth).put_on_roster!
    sign_in_as(accounts(:bob))

    get directory_path
    assert_select ".directory__name", text: "Wren"
    assert_select ".directory__item--roster", text: /Moth/

    get directory_path, params: { field: hometown.id, value: "raven" }
    assert_select ".directory__name", text: "Wren"
    assert_select ".directory__name", text: "Sable", count: 0

    get roster_path
    assert_select ".directory__name", text: "Moth"
    assert_select ".directory__name", text: "Wren", count: 0
  end

  test "an archived account can't log in and its characters are retired or rostered" do
    characters(:wren).update!(roster_when_idle: true)
    sign_in_as(accounts(:scribe))
    post archive_admin_account_path(accounts(:alice))

    assert accounts(:alice).reload.archived?
    assert_nil Account.log_in("alice", "password")
    assert characters(:wren).reload.on_roster?
    assert characters(:moth).reload.retired?
    assert_not characters(:moth).on_roster?
  end

  test "a player can't archive accounts, and a Scribe can't archive a Wellkeeper" do
    sign_in_as(accounts(:bob))
    post archive_admin_account_path(accounts(:alice))
    assert_not accounts(:alice).reload.archived?

    sign_in_as(accounts(:scribe))
    post archive_admin_account_path(accounts(:wellkeeper))
    assert_not accounts(:wellkeeper).reload.archived?
  end

  test "only a Founder can delete an account, and only one that never had characters" do
    empty = Account.create!(display_name: "Newbie", email: "newbie@example.com", password: "Secret12345")

    sign_in_as(accounts(:wellkeeper))
    delete admin_account_path(empty)
    assert Account.exists?(empty.id)

    sign_in_as(accounts(:founder))
    delete admin_account_path(accounts(:alice))
    assert Account.exists?(accounts(:alice).id)

    delete admin_account_path(empty)
    assert_not Account.exists?(empty.id)
  end
end
