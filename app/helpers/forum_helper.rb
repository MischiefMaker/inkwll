# Forum boards: post formatting and who-may-post wording.
module ForumHelper
  POSTER_LABELS = {
    "everyone" => "Anyone with an account",
    "staff" => "Staff only",
    "senior_staff" => "Scribes and Wellkeepers only",
    "nobody" => "Nobody (no replies)"
  }.freeze

  # A post's Markdown as HTML, made safe the same way as wiki pages.
  def render_forum_post(text)
    html = Commonmarker.to_html(text.to_s.dup.force_encoding("UTF-8").scrub,
      options: { render: { unsafe: false }, extension: { table: true, strikethrough: true, autolink: true } })
    tag.div sanitize(html, tags: WikiHelper::WIKI_TAGS, attributes: %w[ href title alt src ]), class: "forum-post__body"
  end

  def forum_poster_options(choices)
    choices.map { |who| [ POSTER_LABELS.fetch(who), who ] }
  end

  def forum_poster_label(who)
    POSTER_LABELS.fetch(who, who)
  end

  # The player's name (posts are out of character), linked to their profile.
  # Who wrote a post or started a thread: the character on an in-character
  # board, otherwise the player.
  def forum_poster(record)
    return forum_author(record.account) unless record.character
    link_to record.character.name, character_path(record.character), **character_name_options(record.character, "forum-author forum-author--character")
  end

  def forum_author(account)
    return tag.span("a departed player", class: "forum-author forum-author--gone muted") unless account
    link_to account.display_name, player_path(account.username), class: "forum-author"
  end
end
