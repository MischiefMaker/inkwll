require "test_helper"

class PlatformTest < ActionDispatch::IntegrationTest
  # --- Features --------------------------------------------------------------

  test "Wellkeepers switch systems on and off, others can't" do
    sign_in_as(accounts(:scribe))
    patch admin_features_path, params: { game_setting: { wiki_enabled: "0" } }
    assert_redirected_to root_path
    assert GameSetting.current.wiki_enabled?

    sign_in_as(accounts(:wellkeeper))
    get edit_admin_features_path
    assert_response :success
    patch admin_features_path, params: { game_setting: { wiki_enabled: "0", grimoire_enabled: "1" } }
    assert_not GameSetting.current.reload.wiki_enabled?
    assert GameSetting.current.grimoire_enabled?
  end

  test "switching the wiki off hides it" do
    GameSetting.current.update!(wiki_enabled: false)
    sign_in_as(accounts(:alice))
    get wiki_pages_path
    assert_response :not_found
    get root_path
    assert_select ".menu__items a", text: "Wiki", count: 0
  end

  # --- Look ------------------------------------------------------------------

  test "only Wellkeepers change the look" do
    sign_in_as(accounts(:scribe))
    get edit_admin_skin_path
    assert_redirected_to root_path
    patch admin_skin_path, params: { game_setting: { custom_css: "body { color: red; }" } }
    assert_nil GameSetting.current.reload.custom_css
  end

  test "colours, fonts and extra CSS make a stylesheet every page loads" do
    GameSetting.current.tap { |settings| settings.apply_preset("plain") }.save!
    sign_in_as(accounts(:wellkeeper))
    colours = GameSetting::Skin::COLOURS.transform_values { |(_, light, _)| light }.merge("accent" => "#B3202A")
    patch admin_skin_path, params: { game_setting: { skin_colours: colours, font_heading: "Georgia, 'Times New Roman', serif",
      custom_css: ".page-title { letter-spacing: 1px; }\n@import url(\"https://fonts.example/x.css\");" } }
    settings = GameSetting.current.reload
    assert_equal({ "accent" => "#b3202a" }, settings.skin_colours)

    get root_path
    assert_select "link[rel=stylesheet][href='#{skin_stylesheet_path(v: settings.updated_at.to_i)}']"

    get skin_stylesheet_path
    assert_equal "text/css", response.media_type
    css = response.body
    assert_includes css, "--color-accent: #b3202a;"
    assert_not_includes css, "--color-bg"
    assert_includes css, "--font-heading: Georgia, 'Times New Roman', serif;"
    assert_includes css, ".page-title { letter-spacing: 1px; }"
    assert css.index("@import") < css.index(":root"), "@import must come first"
  end

  test "fonts and colours can't break out of the stylesheet" do
    sign_in_as(accounts(:wellkeeper))
    patch admin_skin_path, params: { game_setting: { font_body: "Arial; } body { display: none" } }
    assert_response :unprocessable_entity
    patch admin_skin_path, params: { game_setting: { skin_colours: { "accent" => "red; } x {" } } }
    assert_response :unprocessable_entity
    assert_equal "wild", GameSetting.current.reload.current_preset
  end

  test "new games start in Slate blue and gold until an admin picks a look" do
    sign_in_as(accounts(:wellkeeper))
    assert_equal "wild", GameSetting.current.current_preset
    get root_path
    assert_select "link[href^='/skin.css']"
    get admin_root_path
    assert_select ".admin-setup__look"

    patch admin_skin_path, params: { preset: "plain" }
    get root_path
    assert_select "link[href^='/skin.css']", count: 0
    get admin_root_path
    assert_select ".admin-setup__look", count: 0
  end

  test "a ready-made look" do
    sign_in_as(accounts(:wellkeeper))

    patch admin_skin_path, params: { preset: "shadow" }
    settings = GameSetting.current.reload
    assert_equal "#b3202a", settings.colour("accent")
    assert_not settings.skin_dark_mode?
    get skin_stylesheet_path
    assert_includes response.body, "color-scheme: light"

    patch admin_skin_path, params: { preset: "plain" }
    assert_not GameSetting.current.reload.skinned?
  end

  test "guests get the skin too" do
    GameSetting.current.update!(custom_css: "body { margin: 0; }")
    get skin_stylesheet_path
    assert_response :success
    assert_includes response.body, "body { margin: 0; }"
  end
end
