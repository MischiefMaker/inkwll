# Turns a wiki page's Markdown into HTML.
#
# Markdown goes through Commonmarker with raw HTML switched off, then through
# Rails' sanitizer, so nothing a player writes can add scripts or styles.
# [[Page name]] and [[Page name|label]] link to other wiki pages.
#
# A line on its own like {{characters group="Ravens"}} shows a live list from
# the game. Each list is drawn by a partial in app/views/wiki_pages/embeds.
module WikiHelper
  EMBED_LINE = /\A\{\{\s*(\w+)(.*?)\}\}\s*\z/
  EMBEDS = %w[ characters character manuscripts settings pages ].freeze

  def render_wiki(text)
    chunks = []
    markdown = []
    text.to_s.dup.force_encoding("UTF-8").scrub.each_line do |line|
      if (match = line.strip.match(EMBED_LINE))
        chunks << wiki_markdown(markdown.join) if markdown.any?
        markdown = []
        chunks << wiki_embed(match[1].downcase, wiki_embed_options(match[2]))
      else
        markdown << line
      end
    end
    chunks << wiki_markdown(markdown.join) if markdown.any?
    tag.div safe_join(chunks), class: "wiki-body"
  end

  private
    def wiki_markdown(text)
      text = text.gsub(/\[\[([^\]|]{1,100})(?:\|([^\]]{1,100}))?\]\]/) do
        name, label = $1, ($2 || $1).strip
        slug = WikiPage.slug_for(name)
        slug.present? ? "[#{label}](#{wiki_page_path(slug)})" : label
      end
      html = Commonmarker.to_html(text, options: { render: { unsafe: false }, extension: { table: true, strikethrough: true, autolink: true } })
      sanitize(html, tags: WIKI_TAGS, attributes: %w[ href title alt src ])
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
      unless EMBEDS.include?(name)
        return tag.p("Unknown list: {{#{name}}}", class: "wiki-embed wiki-embed--unknown muted")
      end
      tag.div render("wiki_pages/embeds/#{name}", options: options), class: "wiki-embed wiki-embed--#{name}"
    end

    def wiki_limit(options, default: 20)
      options[:limit].to_s.to_i.clamp(1, 100).then { |n| options[:limit] ? n : default }
    end
end
