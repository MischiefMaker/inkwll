require "test_helper"

class GroupPagesTest < ActionDispatch::IntegrationTest
  setup do
    @group = CharacterGroup.create!(name: "House Corvin", colour: "#224466", ranks: "Lord\nKnight\nSquire")
    characters(:wren).update!(character_group: @group)
    characters(:sable).update!(character_group: @group)
  end

  test "everyone, guests too, can read a group's page and board" do
    characters(:sable).update!(group_rank: "Knight")
    get group_path(@group)
    assert_response :success
    assert_select ".group-page__member-name", text: "Wren"
    assert_select ".group-page__rank", text: "Knight"
    assert_select ".group-page__manage", count: 0
    get forum_board_path(@group.board)
    assert_response :success
  end

  test "members are listed leaders first, then by rank" do
    characters(:wren).update!(group_rank: "Squire")
    characters(:sable).update!(group_rank: "Lord")
    get group_path(@group)
    assert_equal %w[ Sable Wren ], css_select(".group-page__member-name").map(&:text)
  end

  test "staff tick leaders, and leaders set ranks but not leaders" do
    sign_in_as(accounts(:wellkeeper))
    patch group_member_path(@group, characters(:wren)), params: { character: { group_leader: "1", group_rank: "Lord" } }
    assert characters(:wren).reload.group_leader?
    assert_equal "Lord", characters(:wren).group_rank
    sign_out

    sign_in_as(accounts(:alice))
    patch group_path(@group), params: { character_group: { ranks: "Lord\nKnight\nPage" } }
    assert_equal %w[ Lord Knight Page ], @group.reload.rank_names
    patch group_member_path(@group, characters(:sable)), params: { character: { group_rank: "Page", group_leader: "1" } }
    assert_equal "Page", characters(:sable).reload.group_rank
    assert_not characters(:sable).group_leader?
    patch group_member_path(@group, characters(:sable)), params: { character: { group_rank: "Emperor" } }
    assert_equal "Page", characters(:sable).reload.group_rank
  end

  test "people who don't lead the group are turned away" do
    sign_in_as(accounts(:bob))
    patch group_path(@group), params: { character_group: { ranks: "Tyrant" } }
    assert_redirected_to group_path(@group)
    assert_equal %w[ Lord Knight Squire ], @group.reload.rank_names
    patch group_member_path(@group, characters(:wren)), params: { character: { group_rank: "Squire" } }
    assert_nil characters(:wren).reload.group_rank
  end

  test "only the group's characters post on its board" do
    board = @group.board!
    sign_in_as(accounts(:alice))
    post forum_board_forum_topics_path(board), params: { forum_topic: { title: "Muster", body: "To arms.", character_id: characters(:moth).id } }
    assert_equal 0, board.topics.count
    post forum_board_forum_topics_path(board), params: { forum_topic: { title: "Muster", body: "To arms.", character_id: characters(:wren).id } }
    assert_equal characters(:wren), board.topics.last.character
    sign_out

    sign_in_as(accounts(:builder))
    post forum_topic_forum_posts_path(board.topics.last), params: { forum_post: { body: "Me too", character_id: characters(:finch).id } }
    assert_equal 1, board.topics.last.posts.count
  end

  test "group boards stay off the general boards list, and moving group clears the rank" do
    board = @group.board!
    get forum_boards_path
    assert_select "a", text: board.name, count: 0
    characters(:wren).update!(group_rank: "Lord", group_leader: true)
    characters(:wren).update!(character_group: nil)
    assert_nil characters(:wren).reload.group_rank
    assert_not characters(:wren).group_leader?
  end
end
