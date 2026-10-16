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
end
