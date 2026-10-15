require "test_helper"

class WikiTest < ActionDispatch::IntegrationTest
  def create_page(title: "House Rules", body: "Be kind.", tags: "rules")
    post wiki_pages_path, params: { wiki_page: { title: title, body: body, tag_list: tags } }
    WikiPage.find_by(title: title)
  end

  test "a player writes a page, edits it, and the history keeps both versions" do
    sign_in_as(accounts(:alice))
    page = create_page
    assert_redirected_to wiki_page_path("house-rules")
    assert_equal [ "rules" ], page.tags

    patch wiki_page_path(page), params: { wiki_page: { title: "House Rules", body: "Be very kind." }, summary: "Kinder" }
    assert_equal "Be very kind.", page.reload.body
    assert_equal 2, page.revisions.count
    assert_equal "Kinder", page.revisions.first.summary

    old = page.revisions.last
    patch wiki_page_revision_path(page, old)
    assert_equal "Be kind.", page.reload.body
    assert_equal 3, page.revisions.count

    get wiki_page_revisions_path(page)
    assert_select ".wiki-history__item", count: 3
  end

  test "Markdown is shown, but scripts and javascript links are stripped" do
    sign_in_as(accounts(:alice))
    page = create_page(title: "Lore", body: "## Old Gods\n\n<script>alert(1)</script>\n\n[click](javascript:alert(1)) <img src=x onerror=alert(1)>\n\nSee [[House Rules|the rules]].")
    get wiki_page_path(page)
    assert_select ".wiki-body h2", text: "Old Gods"
    assert_select ".wiki-body script", count: 0
    assert_select ".wiki-body img", count: 0
    assert_select ".wiki-body a[href^='javascript']", count: 0
    assert_select ".wiki-body a[href='/wiki/house-rules']", text: "the rules"
  end

  test "live lists show game data, and only what the reader may see" do
    profile = "{{characters}}\n{{character name=\"sable\"}}\n{{manuscripts}}\n{{nonsense}}"
    scenes(:secret).update!(finished_at: Time.current)
    sign_in_as(accounts(:alice))
    page = create_page(title: "People", body: profile)
    get wiki_page_path(page)
    assert_select ".wiki-characters__name", text: "Wren"
    assert_select ".wiki-character__name", text: "Sable"
    assert_select ".wiki-manuscripts__title", text: scenes(:secret).title, count: 0
    assert_select ".wiki-embed--unknown", text: /nonsense/
  end

  test "a missing page offers to start it" do
    sign_in_as(accounts(:alice))
    get wiki_page_path("the-old-gods")
    assert_response :not_found
    assert_select "a[href='#{new_wiki_page_path(title: "The old gods")}']"
  end

  test "renaming a page keeps its old address working" do
    sign_in_as(accounts(:alice))
    page = create_page
    patch wiki_page_path(page), params: { wiki_page: { title: "Table Manners" } }
    patch wiki_page_path("table-manners"), params: { wiki_page: { title: "Good Manners" } }

    get wiki_page_path("house-rules")
    assert_redirected_to wiki_page_path("good-manners")
    get wiki_page_path("table-manners")
    assert_redirected_to wiki_page_path("good-manners")

    # A new page can take an old address, and then wins it.
    create_page(title: "House Rules", body: "New rules.")
    get wiki_page_path("house-rules")
    assert_response :success
    assert_select ".wiki-body", text: /New rules/
  end

  test "staff lock a page, then players can't change it" do
    sign_in_as(accounts(:alice))
    page = create_page
    post wiki_page_lock_path(page)
    assert_not page.reload.locked?

    sign_in_as(accounts(:builder))
    post wiki_page_lock_path(page)
    assert page.reload.locked?

    sign_in_as(accounts(:alice))
    patch wiki_page_path(page), params: { wiki_page: { body: "Anarchy!" } }
    assert_equal "Be kind.", page.reload.body
    get edit_wiki_page_path(page)
    assert_redirected_to wiki_page_path(page)
    patch wiki_page_revision_path(page, page.revisions.last)
    assert_equal 1, page.revisions.count

    sign_in_as(accounts(:builder))
    patch wiki_page_path(page), params: { wiki_page: { body: "Be kind, please." } }
    assert_equal "Be kind, please.", page.reload.body
  end

  test "only staff put pages in the Menu" do
    sign_in_as(accounts(:alice))
    page = create_page
    patch wiki_page_path(page), params: { wiki_page: { body: "Be kind.", menu_position: 1 } }
    assert_nil page.reload.menu_position

    sign_in_as(accounts(:scribe))
    patch wiki_page_path(page), params: { wiki_page: { menu_position: 1 } }
    assert_equal 1, page.reload.menu_position
    get root_path
    assert_select ".menu__wiki-page", text: "House Rules"
  end

  test "only Scribes and Wellkeepers delete pages" do
    sign_in_as(accounts(:alice))
    page = create_page
    delete wiki_page_path(page)
    assert WikiPage.exists?(page.id)

    sign_in_as(accounts(:builder))
    delete wiki_page_path(page)
    assert WikiPage.exists?(page.id)

    sign_in_as(accounts(:scribe))
    delete wiki_page_path(page)
    assert_not WikiPage.exists?(page.id)
  end

  test "search and tags filter the list" do
    sign_in_as(accounts(:alice))
    create_page
    create_page(title: "The Old Gods", body: "Ancient and hungry.", tags: "lore")
    get wiki_pages_path, params: { tag: "lore" }
    assert_select ".wiki__title", text: "The Old Gods"
    assert_select ".wiki__title", text: "House Rules", count: 0
    get wiki_pages_path, params: { q: "hungry" }
    assert_select ".wiki__title", count: 1
  end

  test "guests can read the wiki but need an account to write" do
    get wiki_pages_path
    assert_response :success
    get new_wiki_page_path
    assert_redirected_to new_session_path
  end

  test "a page can't be called new" do
    sign_in_as(accounts(:alice))
    assert_no_difference "WikiPage.count" do
      create_page(title: "New")
    end
  end

  test "preview shows the page without saving or running scripts" do
    sign_in_as(accounts(:alice))
    assert_no_difference "WikiPage.count" do
      post preview_wiki_pages_path, params: { body: "## Hello\n\n<script>alert(1)</script>" }
    end
    assert_response :success
    assert_select "h2", text: "Hello"
    assert_select "script", count: 0
  end

  test "guests are turned away from the preview" do
    post preview_wiki_pages_path, params: { body: "## Hello" }
    assert_redirected_to new_session_path
  end
end
