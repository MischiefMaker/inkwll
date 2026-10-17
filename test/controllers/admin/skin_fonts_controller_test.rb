require "test_helper"

class Admin::SkinFontsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @font = GameSetting.current.skin_fonts.new(family: "Cinzel", weight: 700)
    @font.file.attach(io: StringIO.new("wOF2" + "\0" * 60), filename: "cinzel-bold.woff2", content_type: SkinFont::CONTENT_TYPE)
    @font.save!
  end

  test "a Wellkeeper sees the game's fonts on the Look page and can remove one" do
    sign_in_as(accounts(:wellkeeper))
    get edit_admin_skin_path
    assert_select ".skin-fonts__item", text: /Cinzel 700/

    assert_difference -> { SkinFont.count }, -1 do
      delete admin_skin_font_path(@font)
    end
    assert_redirected_to edit_admin_skin_path
    assert_not_includes GameSetting.current.skin_css, "Cinzel"
  end

  test "a Scribe can't remove a font" do
    sign_in_as(accounts(:scribe))
    assert_no_difference -> { SkinFont.count } do
      delete admin_skin_font_path(@font)
    end
    assert_redirected_to root_path
  end

  test "a visitor who isn't logged in can't remove a font" do
    assert_no_difference -> { SkinFont.count } do
      delete admin_skin_font_path(@font)
    end
    assert_response :redirect
  end

  test "the skin stylesheet declares the game's fonts" do
    get skin_stylesheet_path
    assert_includes response.body, %(font-family: "Cinzel")
  end

  test "a Wellkeeper sets the font for big titles on the Look page" do
    sign_in_as(accounts(:wellkeeper))
    get edit_admin_skin_path
    assert_select "input[name='game_setting[font_title]']"

    patch admin_skin_path, params: { game_setting: { font_title: "Cinzel, serif" } }
    assert_equal "Cinzel, serif", GameSetting.current.font_title
  end

  test "a Scribe can't set the font for big titles" do
    sign_in_as(accounts(:scribe))
    patch admin_skin_path, params: { game_setting: { font_title: "Cinzel, serif" } }
    assert_nil GameSetting.current.font_title
  end
end
