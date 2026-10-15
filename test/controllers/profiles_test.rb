require "test_helper"

class ProfilesTest < ActionDispatch::IntegrationTest
  test "private fields show only to the player and staff" do
    characters(:wren).update!(profile: { profile_fields(:background).id => "A secret past" })

    sign_in_as(accounts(:bob))
    get character_path(characters(:wren), tab: "application")
    assert_select "body", text: /A secret past/, count: 0

    sign_in_as(accounts(:alice))
    get character_path(characters(:wren), tab: "application")
    assert_select ".profile-fields", text: /A secret past/
  end

  test "drafts are only shown to their player and staff" do
    draft = accounts(:alice).characters.create!(name: "Drafty")
    sign_in_as(accounts(:bob))
    get character_path(draft)
    assert_response :not_found
  end

  test "staff approve or return applications" do
    character = accounts(:alice).characters.create!(name: "Applicant", status: "draft")
    character.update!(profile: { profile_fields(:hometown).id => "York" })
    character.submit!

    sign_in_as(accounts(:scribe))
    get admin_applications_path
    assert_select "a", text: "Applicant"
    patch admin_application_path(character), params: { decision: "return", note: "More background, please." }
    assert character.reload.returned?
    assert_equal "More background, please.", character.review_note
  end

  test "players can add gallery pictures and relationships" do
    sign_in_as(accounts(:alice))
    post character_gallery_images_path(characters(:wren)), params: { gallery_image: { image: fixture_file_upload("pixel.png", "image/png"), caption: "At the docks" } }
    assert_equal "At the docks", characters(:wren).gallery_images.last.caption

    post character_relationships_path(characters(:wren)), params: { relationship: { other_character_name: "Sable", kind: "rival", note: "Old grudge" } }
    get character_path(characters(:wren), tab: "relationships")
    assert_select ".relationships__name", text: "Sable"
  end

  test "you can't change someone else's gallery" do
    sign_in_as(accounts(:bob))
    post character_gallery_images_path(characters(:wren)), params: { gallery_image: { caption: "x" } }
    assert_response :not_found
  end

  test "staff edit the profile fields" do
    sign_in_as(accounts(:wellkeeper))
    post admin_profile_fields_path, params: { profile_field: { name: "Eye colour", section: "demographics", field_type: "text", public: "1" } }
    assert ProfileField.exists?(name: "Eye colour")
  end

  test "changing an answer that's already filled in saves it" do
    character = characters(:wren)
    character.update!(profile: { profile_fields(:hometown).id => "York" })
    sign_in_as(accounts(:alice))
    patch character_path(character), params: { character: { profile: { profile_fields(:hometown).id => "Leeds" } } }
    assert_equal "Leeds", character.reload.profile_value_for(profile_fields(:hometown)).value
  end

  test "a locked field can't be changed by the player once approved, but staff can" do
    character = characters(:wren)
    field = profile_fields(:hometown)
    character.update!(profile: { field.id => "York" })
    field.update!(player_can_edit: false)

    sign_in_as(accounts(:alice))
    get edit_character_path(character)
    assert_select ".character-form__locked-value", text: /York/
    patch character_path(character), params: { character: { profile: { field.id => "Leeds" } } }
    assert_equal "York", character.reload.profile_value_for(field).value

    character.profile_editor = accounts(:wellkeeper)
    character.update!(profile: { field.id => "Leeds" })
    assert_equal "Leeds", character.reload.profile_value_for(field).value
  end

  test "a Picture field takes an image on the character form and shows it on the profile" do
    field = ProfileField.create!(name: "Description", section: "demographics", field_type: "image")
    sign_in_as(accounts(:alice))
    get edit_character_path(characters(:wren))
    assert_select "input[type=file][name=?]", "character[profile][#{field.id}]"

    patch character_path(characters(:wren)), params: { character: { profile: { field.id => fixture_file_upload("pixel.png", "image/png") } } }
    value = characters(:wren).reload.profile_value_for(field)
    assert value.image.attached?
    get character_path(characters(:wren))
    assert_select "img.profile-fields__picture"

    # Saving without a new file keeps the picture; ticking Remove takes it away.
    patch character_path(characters(:wren)), params: { character: { name: "Wren" } }
    assert value.reload.image.attached?
    patch character_path(characters(:wren)), params: { character: { remove_profile_pictures: [ field.id ] } }
    assert_nil value.reload.value
  end

  test "a Picture field won't take something that isn't a picture" do
    field = ProfileField.create!(name: "Description", section: "demographics", field_type: "image")
    sign_in_as(accounts(:alice))
    patch character_path(characters(:wren)), params: { character: { profile: { field.id => fixture_file_upload("not-a-picture.txt", "text/plain") } } }
    assert_response :unprocessable_entity
    assert_nil characters(:wren).reload.profile_value_for(field)
  end

  test "a Picture field can't go beside Passages or on roster applications" do
    field = ProfileField.new(name: "Looks", section: "demographics", field_type: "image", on_passages: true, ask_on_roster: true)
    assert_not field.valid?
    assert field.errors[:on_passages].any?
    assert field.errors[:ask_on_roster].any?
  end

  test "staff reviewing an application can open the SOUL sheet, gallery and relationships" do
    character = accounts(:alice).characters.create!(name: "Applicant", status: "draft")
    character.update!(profile: { profile_fields(:hometown).id => "York" })
    character.submit!

    sign_in_as(accounts(:scribe))
    get admin_application_path(character)
    assert_select ".application-tabs__tab", text: "SOUL"
    assert_select ".application-tabs__tab", text: "Gallery"
    assert_select ".application-tabs__tab", text: "Relationships"

    %w[ soul gallery relationships ].each do |tab|
      get admin_application_path(character, tab: tab)
      assert_response :success
      assert_select ".application-panel--#{tab}"
      assert_select "form[action=?]", character_sheet_path(character), count: 0 if tab == "soul"
    end
    assert_select ".application-review", count: 1
  end

  test "approving a character starts Goal and Secret Inklings from the matching answers" do
    goals = ProfileField.create!(name: "Goals", section: "application", field_type: "long_text", public: false, inkling_kind: "goal")
    secrets = ProfileField.create!(name: "Secrets", section: "application", field_type: "long_text", public: false, inkling_kind: "secret")
    ProfileField.create!(name: "Quirk", section: "application", field_type: "text")
    character = accounts(:alice).characters.create!(name: "Applicant", status: "draft")
    character.update!(profile: { profile_fields(:hometown).id => "York", goals.id => "Become mayor.", secrets.id => "Is a spy." })
    character.submit!

    sign_in_as(accounts(:scribe))
    assert_difference "Inkling.count", 2 do
      patch admin_application_path(character), params: { decision: "approve" }
    end
    goal = Inkling.find_by!(character: character, kind: "goal")
    assert_equal "Goals", goal.title
    assert_equal accounts(:alice), goal.creator
    assert_equal "Become mayor.", goal.entries.first.body
    assert_nil goal.staff_visible_at, "staff don't see it until the player sends it"
    assert Inkling.exists?(character: character, kind: "secret")

    assert_no_difference "Inkling.count" do
      character.start_inklings_from_profile!
    end
  end

  test "a field can only start an Inkling of a type players start, from a text answer" do
    assert_not ProfileField.new(name: "X", inkling_kind: "hint").valid?
    assert_not ProfileField.new(name: "X", field_type: "date", inkling_kind: "goal").valid?
    assert ProfileField.new(name: "X", field_type: "long_text", inkling_kind: "goal").valid?
  end

  test "the Active Chapters tab shows to the player and staff, listing open Chapters, but not hidden ones to staff" do
    wren = characters(:wren)
    hidden = Scene.start!(character: wren, room: wren.room, title: "Secret doings", visibility: "hidden", pose_mode: Scene.pose_modes.keys.first)

    sign_in_as(accounts(:alice))
    get character_path(wren, tab: "chapters")
    assert_select ".profile-tabs__tab", text: /Active Chapters/
    assert_select ".character-chapters__item a.scene-list__title", text: "Duel at Dawn"
    assert_select ".character-chapters__item a.scene-list__title", text: "Secret doings"

    sign_in_as(accounts(:wellkeeper))
    get character_path(wren, tab: "chapters")
    assert_select ".profile-tabs__tab", text: /Active Chapters/
    assert_select ".character-chapters__item a.scene-list__title", text: "Duel at Dawn"
    assert_select ".character-chapters__item a.scene-list__title", text: "Secret doings", count: 0

    sign_in_as(accounts(:bob))
    get character_path(wren, tab: "chapters")
    assert_select ".profile-tabs__tab", text: /Active Chapters/, count: 0
    assert_select ".character-chapters", count: 0
    assert hidden.visibility_hidden?
  end
end
