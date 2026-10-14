require "test_helper"

class Scenes::ParticipationsControllerTest < ActionDispatch::IntegrationTest
  test "joining from another Setting walks the character there first" do
    sign_in_as(accounts(:builder))
    characters(:finch).update!(room: rooms(:garden))
    accounts(:builder).update!(active_character: characters(:finch))

    post scene_participation_path(scenes(:duel))

    assert_redirected_to scene_path(scenes(:duel))
    assert_equal rooms(:commons), characters(:finch).reload.room
    assert_includes scenes(:duel).reload.characters, characters(:finch)
  end

  test "private Chapters need an invitation" do
    sign_in_as(accounts(:bob))

    post scene_participation_path(scenes(:tea))
    assert_not_includes scenes(:tea).reload.characters, characters(:sable)

    scenes(:tea).invitations.create!(character: characters(:sable))
    post scene_participation_path(scenes(:tea))
    assert_includes scenes(:tea).reload.characters, characters(:sable)
  end

  test "leaving a Chapter" do
    sign_in_as(accounts(:alice))
    delete scene_participation_path(scenes(:duel))
    assert_redirected_to room_path(rooms(:commons))
    assert_not_includes scenes(:duel).reload.characters, characters(:wren)
  end

  test "only Storytellers can take the storyteller role" do
    sign_in_as(accounts(:alice))
    patch scene_participation_path(scenes(:duel))
    assert scene_participants(:duel_wren).reload.player?

    accounts(:alice).update!(storyteller: true)
    patch scene_participation_path(scenes(:duel))
    assert scene_participants(:duel_wren).reload.storyteller?
  end

  test "inviting a character by name" do
    sign_in_as(accounts(:alice))
    accounts(:alice).update!(active_character: characters(:moth))
    post scene_invitations_path(scenes(:tea)), params: { name: "sable" }
    assert scenes(:tea).invited?(characters(:sable))
  end

  test "nobody can be invited into a finished Chapter" do
    sign_in_as(accounts(:bob))
    accounts(:bob).update!(active_character: characters(:sable))
    scenes(:secret).finish!(by: characters(:sable))

    post scene_invitations_path(scenes(:secret)), params: { name: "wren" }
    assert_not scenes(:secret).reload.invited?(characters(:wren))
    assert_not scenes(:secret).readable_by?(accounts(:alice))
  end
end
