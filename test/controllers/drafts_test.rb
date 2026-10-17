require "test_helper"

# Drafts are kept in the browser by the draft Stimulus controller; these check
# the writing boxes are wired up to it.
class DraftsTest < ActionDispatch::IntegrationTest
  test "the Passage box and the Messages box keep drafts" do
    sign_in_as(accounts(:alice))
    get scene_path(scenes(:duel))
    assert_select "form[data-controller~=draft][data-draft-key-value=?] textarea[data-draft-target=field]", "passage-#{scenes(:duel).id}-#{characters(:wren).id}"
    assert_select "meta[name=inkwll-account][content=?]", accounts(:alice).id.to_s

    get new_conversation_path
    assert_select "form[data-controller~=draft] textarea[data-draft-target=field]"
  end
end
