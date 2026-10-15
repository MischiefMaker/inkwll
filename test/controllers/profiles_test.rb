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
end
