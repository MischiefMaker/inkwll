# Turns a wiki page's Markdown into HTML.
#
# Markdown goes through Commonmarker with raw HTML switched off, then through
# Rails' sanitizer, so nothing a player writes can add scripts or styles.
# [[Page name]] and [[Page name|label]] link to other wiki pages.
#
# A bullet that names a character group ("15, male, Ravenclaw") takes that
# group's colour, so lists sorted by house or faction read at a glance.
#
# A line on its own like {{characters group="Ravens"}} shows a live list from
# the game. Each list is drawn by a partial in app/views/wiki_pages/embeds.
#
# An infobox is a boxed summary of facts beside the page, written between
# {{infobox}} and {{/infobox}} lines, one "Label: value" per line.
module WikiHelper
  EMBED_LINE = /\A\{\{\s*(\w+)(.*?)\}\}\s*\z/
  EMBEDS = %w[ characters character manuscripts settings pages tags backlinks ].freeze
  INFOBOX_START = /\A\{\{\s*infobox\b(.*?)\}\}\s*\z/i
  INFOBOX_END = /\A\{\{\s*\/\s*infobox\s*\}\}\s*\z/i
  INFOBOX_ROWS = 40

  # page: the wiki page being shown, for lists about it such as {{backlinks}}.
  def render_wiki(text, page: nil)
    @wiki_page = page
    chunks = []
    markdown = []
    infobox = nil
    text.to_s.dup.force_encoding("UTF-8").scrub.each_line do |line|
      stripped = line.strip
      if infobox
        if stripped.match?(INFOBOX_END)
          chunks << wiki_infobox(*infobox)
          infobox = nil
        else
          infobox.last << stripped
        end
      elsif (match = stripped.match(INFOBOX_START))
        chunks << wiki_markdown(markdown.join) if markdown.any?
        markdown = []
        infobox = [ wiki_embed_options(match[1]), [] ]
      elsif (match = stripped.match(EMBED_LINE))
        chunks << wiki_markdown(markdown.join) if markdown.any?
        markdown = []
        chunks << wiki_embed(match[1].downcase, wiki_embed_options(match[2]))
      else
        markdown << line
      end
    end
    chunks << wiki_infobox(*infobox) if infobox
    chunks << wiki_markdown(markdown.join) if markdown.any?
    tag.div safe_join(chunks), class: "wiki-body"
  end

  # A page's first paragraph as plain text, for lists of pages.
  def wiki_summary(page, length: 200)
    line = page.body.to_s.each_line.map(&:strip).find do |text|
      text.present? && !text.start_with?("#", "{{", "|", "!", "---", ">") && !text.match?(/\A[-*]\s/)
    end
    return unless line
    line = line.gsub(/\[\[([^\]|]{1,100})(?:\|([^\]]{1,100}))?\]\]/) { ($2 || $1).strip }
    strip_tags(Commonmarker.to_html(line, options: { render: { unsafe: false } })).squish.truncate(length, separator: " ")
  end

  private
    def wiki_markdown(text)
      text = text.gsub(/\[\[([^\]|]{1,100})(?:\|([^\]]{1,100}))?\]\]/) do
        name, label = $1, ($2 || $1).strip
        slug = WikiPage.slug_for(name)
        slug.present? ? "[#{label}](#{wiki_page_path(slug)})" : label
      end
      html = Commonmarker.to_html(text, options: { render: { unsafe: false }, extension: { table: true, strikethrough: true, autolink: true } })
      colour_group_bullets(sanitize(html, tags: WIKI_TAGS, attributes: %w[ href title alt src ]))
    end

    # Adds the group colour to each bullet that names a group, as the same
    # --group-colour the game uses for character names. The colour comes from
    # the group itself, which only staff can set, and is checked to be a hex
    # colour, so nothing a player writes ends up in the style.
    def colour_group_bullets(html)
      @wiki_groups ||= CharacterGroup.pluck(:name, :colour).filter_map do |name, colour|
        [ /(?<![[:alnum:]])#{Regexp.escape(name)}(?![[:alnum:]])/i, colour ] if colour.match?(/\A#\h{6}\z/)
      end
      return html if @wiki_groups.empty? || !html.include?("<li")

      fragment = Nokogiri::HTML5.fragment(html)
      fragment.css("li").each do |item|
        text = item.xpath("text()|*[not(self::ul or self::ol)]").map(&:text).join
        found = @wiki_groups.filter_map { |pattern, colour| [ text =~ pattern, colour ] if text.match?(pattern) }.min_by(&:first)
        next unless found
        item["class"] = "wiki-body__grouped"
        item["style"] = "--group-colour: #{found.last}"
      end
      fragment.to_html.html_safe
    end

    WIKI_TAGS = %w[ h1 h2 h3 h4 h5 h6 p br hr strong em del a ul ol li blockquote code pre img
                    table thead tbody tr th td ].freeze

    # key="value", key=value, or a bare word (which means true).
    def wiki_embed_options(text)
      text.to_s.scan(/(\w+)(?:=(?:"([^"]*)"|(\S+)))?/).to_h do |key, quoted, plain|
        [ key.downcase.to_sym, (quoted || plain || true) ]
      end
    end

    def wiki_embed(name, options)
      # Places were called Settings at first; both spellings work.
      name = "settings" if name == "places"
      options[:setting] ||= options[:place] if options.key?(:place)
      unless EMBEDS.include?(name)
        return tag.p("Unknown list: {{#{name}}}", class: "wiki-embed wiki-embed--unknown muted")
      end
      tag.div render("wiki_pages/embeds/#{name}", options: options, page: @wiki_page), class: "wiki-embed wiki-embed--#{name}"
    end

    # Each line is "Label: value", a "## Heading" across the box, a picture
    # (![words](address)) or plain words across the box. Values can use the
    # same Markdown and [[links]] as the rest of the page.
    def wiki_infobox(options, lines)
      title = options[:title].is_a?(String) ? options[:title] : @wiki_page&.title
      rows = lines.compact_blank.first(INFOBOX_ROWS).map do |line|
        if line.start_with?("![")
          [ :picture, wiki_inline(line) ]
        elsif (heading = line[/\A#+\s*(.+)\z/, 1])
          [ :heading, heading ]
        elsif (match = line.match(/\A([^:]{1,40}):\s*(.*)\z/)) && !match[1].include?("http")
          [ :fact, match[1].strip, wiki_inline(match[2]) ]
        else
          [ :text, wiki_inline(line) ]
        end
      end
      render "wiki_pages/infobox", title: title, rows: rows
    end

    # A bit of Markdown without the paragraph around it.
    def wiki_inline(text)
      html = wiki_markdown(text).to_str.strip.delete_prefix("<p>").delete_suffix("</p>")
      sanitize(html, tags: WIKI_TAGS, attributes: %w[ href title alt src ])
    end

    def wiki_limit(options, default: 20)
      options[:limit].to_s.to_i.clamp(1, 100).then { |n| options[:limit] ? n : default }
    end
end
