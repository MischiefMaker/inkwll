require "test_helper"

class AdminBatchesTest < ActionDispatch::IntegrationTest
  test "a Wellkeeper retires several characters at once" do
    sign_in_as(accounts(:wellkeeper))
    get admin_characters_path
    assert_select "input[type=checkbox][name='character_ids[]'][form=character-batch]"

    post admin_character_batch_path, params: { decision: "retire", character_ids: [ characters(:wren).id, characters(:sable).id ] }
    assert characters(:wren).reload.retired?
    assert characters(:sable).reload.retired?
    assert_not characters(:moth).reload.retired?
  end

  test "a Wellkeeper puts several characters on the roster at once" do
    sign_in_as(accounts(:wellkeeper))
    post admin_character_batch_path, params: { decision: "roster", character_ids: [ characters(:wren).id, characters(:moth).id ] }
    assert characters(:wren).reload.on_roster?
    assert characters(:moth).reload.on_roster?
  end

  test "players and Scribes can't use the character tick boxes" do
    [ :alice, :scribe ].each do |who|
      sign_in_as(accounts(who))
      post admin_character_batch_path, params: { decision: "retire", character_ids: [ characters(:sable).id ] }
      assert_not characters(:sable).reload.retired?
    end
  end

  test "staff archive several players at once, skipping those above them and themselves" do
    sign_in_as(accounts(:scribe))
    get admin_accounts_path
    assert_select "input[type=checkbox][name='account_ids[]'][form=account-batch]"

    post admin_account_batch_path, params: { decision: "archive", account_ids: [ accounts(:alice).id, accounts(:bob).id, accounts(:wellkeeper).id, accounts(:scribe).id ] }
    assert accounts(:alice).reload.archived?
    assert accounts(:bob).reload.archived?
    assert_not accounts(:wellkeeper).reload.archived?
    assert_not accounts(:scribe).reload.archived?
  end

  test "players can't archive anyone" do
    sign_in_as(accounts(:alice))
    post admin_account_batch_path, params: { decision: "archive", account_ids: [ accounts(:bob).id ] }
    assert_not accounts(:bob).reload.archived?
  end
end
