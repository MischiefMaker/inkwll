require "test_helper"

class GameSettingSkinTest < ActiveSupport::TestCase
  test "the font for big titles is a CSS variable, and only when it is set" do
    settings = GameSetting.current
    assert_not_includes settings.skin_css, "--font-title"

    settings.update!(font_title: "'Great Vibes', cursive")
    assert_includes settings.skin_css, "--font-title: 'Great Vibes', cursive;"
    assert settings.skinned?
  end

  test "the title font can't carry anything but font names" do
    settings = GameSetting.current
    settings.font_title = "x; } body { display: none"
    assert_not settings.valid?
    settings.font_title = "'Great Vibes"
    assert_not settings.valid?
  end

  test "picking a ready-made look clears the title font, as it does the heading font" do
    settings = GameSetting.current
    settings.update!(font_title: "Montez, cursive")
    settings.apply_preset("shadow")
    assert_nil settings.font_title
  end
end
