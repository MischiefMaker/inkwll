require "test_helper"

class WorldPackTest < ActiveSupport::TestCase
  PIXEL = Base64.strict_encode64(Rails.root.join("test/fixtures/files/pixel.png").binread)

  def pack(**overrides)
    WorldPack.new({
      "format" => WorldPack::FORMAT,
      "name" => "Test World",
      "game" => { "name" => "Old Game", "blurb" => "It was the best of times.", "icon" => "pixel" },
      "look" => { "font_body" => "Oswald, sans-serif", "custom_css" => ".x { color: red; }" },
      "areas" => [
        { "name" => "Hogwarts", "summary" => "A school.", "entrance" => "Foyer", "image" => "pixel" },
        { "name" => "Grounds", "parent" => "Hogwarts" }
      ],
      "places" => [
        { "name" => "Foyer", "area" => "Hogwarts", "description" => "A big hall." },
        { "name" => "Lake", "area" => "Grounds", "kind" => "outdoor" }
      ],
      "paths" => [
        { "from" => "Foyer", "to" => "Lake", "direction" => "OUT" },
        { "from" => "Lake", "to" => "Foyer", "kind" => "building" }
      ],
      "wiki_pages" => [ { "title" => "Our Story", "body" => "Once upon a time.", "tags" => [ "Lore" ], "locked" => true } ],
      "boards" => [ { "name" => "Newest News", "was" => "Old News", "who_can_start" => "staff" } ],
      "images" => { "pixel" => { "content_type" => "image/png", "filename" => "pixel.png", "data" => PIXEL } }
    }.merge(overrides.transform_keys(&:to_s)))
  end

  test "parse turns away files that aren't world packs" do
    assert_raises(WorldPack::Invalid) { WorldPack.parse("not json") }
    assert_raises(WorldPack::Invalid) { WorldPack.parse({ "format" => "something else" }.to_json) }
    assert_equal "Test World", WorldPack.parse(pack.data.to_json).name
  end

  test "a pack must name things that exist" do
    assert_raises(WorldPack::Invalid) { pack(places: [ { "name" => "Lost", "area" => "Nowhere" } ], paths: []) }
    assert_raises(WorldPack::Invalid) { pack(paths: [ { "from" => "Foyer", "to" => "Moon" } ]) }
    assert_raises(WorldPack::Invalid) { pack(areas: [ { "name" => "Hogwarts", "icon" => "missing" } ], places: [], paths: []) }
  end

  test "importing sets up the game, areas, places, paths, wiki and boards" do
    ForumBoard.create!(name: "Old News")
    pack.import!(by: accounts(:founder))

    settings = GameSetting.current
    assert_equal "Old Game", settings.game_name
    assert settings.icon.attached?
    assert_equal "Oswald, sans-serif", settings.font_body

    hogwarts = Area.find_by!(name: "Hogwarts")
    assert_equal hogwarts, Area.find_by!(name: "Grounds").parent
    assert hogwarts.image.attached?
    foyer = Room.find_by!(name: "Foyer")
    assert_equal foyer, hogwarts.entrance_room
    assert_equal "outdoor", Room.find_by!(name: "Lake").kind
    assert_equal "OUT", foyer.exits.find_by!(name: "Lake").direction

    page = WikiPage.find_by!(slug: WikiPage.slug_for("Our Story"))
    assert_equal [ "lore" ], page.tags
    assert page.locked_at

    assert ForumBoard.exists?(name: "Newest News", who_can_start: "staff")
    assert_not ForumBoard.exists?(name: "Old News")
  end

  test "importing the same pack twice changes nothing the second time" do
    pack.import!(by: accounts(:founder))
    counts = -> { [ Area.count, Room.count, Exit.count, WikiPage.count, ForumBoard.count, ActiveStorage::Blob.count, WikiRevision.count ] }
    before = counts.call
    pack.import!(by: accounts(:founder))
    assert_equal before, counts.call
    assert pack.preview.none? { |change| change.action == "add" }
  end

  test "The Prologue gets a Path into each top-level area" do
    prologue = Room.create_prologue!
    pack.import!(by: accounts(:founder))
    assert prologue.exits.exists?(destination_room: Room.find_by!(name: "Foyer"))
  end

  test "removing what the pack leaves out keeps The Prologue and busy places" do
    prologue = Room.create_prologue!
    garden, tower, castle = rooms(:garden).id, rooms(:tower).id, areas(:castle).id
    pack.import!(by: accounts(:founder), remove_unlisted: true)

    assert Room.exists?(prologue.id)
    assert Room.exists?(rooms(:commons).id), "characters are in The Commons"
    assert Room.exists?(rooms(:hall).id), "characters are in North Hall"
    assert_not Room.exists?(garden)
    assert_not Room.exists?(tower)
    assert Area.exists?(areas(:world).id), "it still holds places that stay"
    assert_not Area.exists?(castle)
    assert Room.exists?(name: "Foyer")
  end

  test "the preview lists what would be removed and what stays" do
    changes = pack.preview(remove_unlisted: true)
    assert changes.any? { |c| c.name == "Garden" && c.action == "remove" }
    assert changes.any? { |c| c.name == "The Commons" && c.action == "keep" }
    assert changes.any? { |c| c.name == "Foyer" && c.action == "add" }
  end
end
