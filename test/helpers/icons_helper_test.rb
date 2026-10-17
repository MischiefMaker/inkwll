require "test_helper"

class IconsHelperTest < ActionView::TestCase
  test "icons are served as a shrunk copy, but animated GIFs are left as they are" do
    room = rooms(:hall)
    room.icon.attach(io: File.open(file_fixture("pixel.png")), filename: "pixel.png", content_type: "image/png")
    assert_not_same room.icon, icon_picture(room.icon)
    assert_equal [ 256, 256 ], icon_picture(room.icon).variation.transformations[:resize_to_limit]

    room.icon.blob.update_column(:content_type, "image/gif")
    assert_same room.icon, icon_picture(room.icon)
  end

  test "chat-sized icons use the small copy made at upload, once it's ready" do
    character = characters(:wren)
    character.icon.attach(io: File.open(file_fixture("pixel.png")), filename: "pixel.png", content_type: "image/png")
    assert_equal [ 256, 256 ], icon_picture(character.icon, tiny: true).variation.transformations[:resize_to_limit]

    character.icon.variant(:tiny).processed
    small = icon_picture(character.icon.reload, tiny: true)
    assert_equal [ 64, 64 ], small.variation.transformations[:resize_to_fill]
    assert small.image.attached?
  end

  test "a player or character icon over the game's limit is refused" do
    GameSetting.current.update!(icon_max_kb: 10)
    account = accounts(:alice)
    account.icon.attach(io: StringIO.new("x" * 11.kilobytes), filename: "big.png", content_type: "image/png")
    assert_not account.valid?
    assert_includes account.errors[:icon].join, "must be smaller than 10 KB"

    GameSetting.current.update!(icon_max_kb: 20)
    assert account.valid?, account.errors.full_messages.to_sentence
  end
end
