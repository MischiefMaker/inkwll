require "test_helper"

class WikiListsTest < ActionDispatch::IntegrationTest
  def page!(title, body: "Some words.", tags: [])
    WikiPage.create!(title: title, body: body, tags: tags)
  end

  test "lists of pages filter by tags and title, sort, and show summaries or a table" do
    page!("House Corvin", body: "# Corvin\n\nThe ravens of the north. **Proud** and old.", tags: %w[ lore houses ])
    page!("House Vane", tags: %w[ lore houses secret ])
    page!("Rules", tags: %w[ rules ])
    list = page!("Index", body: "{{pages tags=\"+lore -secret\" show=\"summary\"}}\n{{pages prefix=\"House \" show=\"table\" order=\"newest\"}}\n{{pages tags=\"rules houses\" order=\"title\"}}\n{{tags}}")
    get wiki_page_path(list)
    assert_response :success
    first, second, third = css_select(".wiki-embed--pages")
    assert_equal [ "House Corvin" ], first.css(".wiki-pages-list__title").map(&:text)
    assert_equal "The ravens of the north. Proud and old.", first.css(".wiki-pages-list__summary").text
    assert_equal [ "House Vane", "House Corvin" ], second.css(".wiki-pages-list__title").map(&:text)
    assert_equal [ "House Corvin", "House Vane", "Rules" ], third.css(".wiki-pages-list__title").map(&:text)
    assert_select ".wiki-tag-cloud__tag", text: "lore"
  end

  test "backlinks list the pages that link here, including by an old name" do
    target = page!("The Old Keep")
    page!("Travels", body: "We rode to [[The Old Keep|the keep]].")
    page!("Unrelated", body: "The Old Keep is mentioned but not linked.")
    target.update!(title: "Ravenhold Keep", body: "{{backlinks}}")
    page!("Maps", body: "See [[Ravenhold Keep]].")
    get wiki_page_path(target)
    assert_equal %w[ Maps Travels ], css_select(".wiki-backlinks .wiki-pages-list__title").map(&:text)
  end

  test "an infobox shows labelled facts, headings and pictures, and stays safe" do
    page = page!("Wren Ashdown", body: <<~WIKI)
      {{infobox}}
      ![Wren](https://example.com/wren.png)
      Born: 1180, in [[Ravenhold Keep]]
      ## Family
      Mother: <script>alert(1)</script>Ysolde
      Just some words
      {{/infobox}}
      Wren is a knight.
    WIKI
    get wiki_page_path(page)
    assert_select ".wiki-infobox__title", text: "Wren Ashdown"
    assert_select ".wiki-infobox__label", text: "Born"
    assert_select ".wiki-infobox__value a[href=?]", wiki_page_path("ravenhold-keep")
    assert_select ".wiki-infobox__heading", text: "Family"
    assert_select ".wiki-infobox__picture img[src=?]", "https://example.com/wren.png"
    assert_select ".wiki-infobox__text", text: "Just some words"
    assert_select ".wiki-infobox script", count: 0
    assert_select ".wiki-body p", text: "Wren is a knight."
  end
end
