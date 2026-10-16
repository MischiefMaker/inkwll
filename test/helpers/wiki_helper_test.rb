require "test_helper"

class WikiHelperTest < ActionView::TestCase
  test "a bullet that names a group takes the group's colour" do
    CharacterGroup.create!(name: "Ravenclaw", colour: "#2255aa")
    CharacterGroup.create!(name: "Slytherin", colour: "#228844")

    html = render_wiki("Notes about Ravenclaw\n\n* 15, male, Ravenclaw (twin)\n* 16, female, Slytherin\n* 17, female, unsorted\n")
    items = Nokogiri::HTML5.fragment(html).css("li")

    assert_equal "--group-colour: #2255aa", items[0]["style"]
    assert_equal "wiki-body__grouped", items[0]["class"]
    assert_equal "--group-colour: #228844", items[1]["style"]
    assert_nil items[2]["style"]
    assert_no_match "group-colour", Nokogiri::HTML5.fragment(html).at_css("p").to_html
  end

  test "group names only match whole words, and nothing a player writes reaches the style" do
    CharacterGroup.create!(name: "Raven", colour: "#2255aa")

    html = render_wiki("* Ravenclaw\n* <span style=\"color:red\">Raven</span>\n")
    items = Nokogiri::HTML5.fragment(html).css("li")

    assert_nil items[0]["style"]
    assert_equal "--group-colour: #2255aa", items[1]["style"]
    assert_no_match "color:red", html
  end
end
