# The game's skin: its colours, fonts and extra CSS, set from Admin → Look.
# They're served as their own stylesheet (see SkinsController), loaded after
# the built-in one, so they override it.
module GameSetting::Skin
  extend ActiveSupport::Concern

  # Each colour the stylesheet uses, with its built-in light and dark values.
  # These must match the variables at the top of application.css.
  COLOURS = {
    "bg" => [ "Page background", "#f7f5f0", "#1c1b1f" ],
    "surface" => [ "Boxes and panels", "#ffffff", "#26252b" ],
    "text" => [ "Text", "#222222", "#e8e6e3" ],
    "muted" => [ "Quieter text", "#6b6b6b", "#a09ea8" ],
    "border" => [ "Lines and borders", "#dcd8ce", "#3a3842" ],
    "accent" => [ "Main colour: links, buttons, headings bar", "#5b3f8c", "#a98be0" ],
    "accent-text" => [ "Text on the main colour", "#ffffff", "#1c1b1f" ],
    "notice" => [ "\"Saved\" messages", "#e6f2e6", "#23362a" ],
    "alert" => [ "Warning messages", "#f8e3e3", "#3d2426" ]
  }.freeze

  COLOUR_FORMAT = /\A#\h{6}\z/
  # Font names: letters, numbers, spaces, commas, hyphens and quotes only, so
  # nothing else can be slipped into the stylesheet.
  FONT_FORMAT = /\A[\p{L}\p{N} ,'"-]*\z/

  # The look a new game starts with, until an admin picks one (owner).
  DEFAULT_PRESET = "wild"

  # Ready-made starting points, after the owner's earlier forum skins.
  PRESETS = {
    "plain" => { name: "Inkwll plain", colours: {}, dark_colours: {}, dark_mode: true, font_heading: nil },
    "shadow" => { name: "Black and red", dark_mode: false, font_heading: "Georgia, 'Times New Roman', serif",
      colours: { "bg" => "#141414", "surface" => "#1f1f1f", "text" => "#e6e1dc", "muted" => "#a39b94", "border" => "#3a2a2a",
                 "accent" => "#b3202a", "accent-text" => "#ffffff", "notice" => "#22301f", "alert" => "#4a1c1f" } },
    "wild" => { name: "Slate blue and gold", dark_mode: false, font_heading: nil,
      colours: { "bg" => "#e9edf2", "surface" => "#ffffff", "text" => "#1f2a36", "muted" => "#5c6b7a", "border" => "#c5ceda",
                 "accent" => "#3d5a80", "accent-text" => "#f6d36b", "notice" => "#e3efe3", "alert" => "#f5e1df" } },
    "mush" => { name: "Old-school MUSH", dark_mode: false, font_body: "'Courier New', Courier, monospace", font_heading: "'Courier New', Courier, monospace",
      colours: { "bg" => "#000000", "surface" => "#000000", "text" => "#f0f0f0", "muted" => "#a8a8a8", "border" => "#555555",
                 "accent" => "#55ffff", "accent-text" => "#000000", "notice" => "#003300", "alert" => "#440000" } },
    "flag" => { name: "Black and white", dark_mode: false, font_heading: "Impact, 'Arial Black', sans-serif",
      colours: { "bg" => "#ffffff", "surface" => "#f2f2f2", "text" => "#111111", "muted" => "#5a5a5a", "border" => "#111111",
                 "accent" => "#111111", "accent-text" => "#ffffff", "notice" => "#e8e8e8", "alert" => "#f0dede" } }
  }.freeze

  # Optional pictures from Admin → Look, each set as a CSS variable:
  # --page-image behind every page, --box-image behind boxes and panels,
  # --intro-image behind the game's name on the front page.
  PICTURES = {
    "page_background" => [ "--page-image", "Page background", "Shown behind every page. Areas and Settings can have their own instead." ],
    "box_background" => [ "--box-image", "Box background", "Shown behind boxes and panels: the header, lists, the OOC chat, Chapter details." ],
    "intro_banner" => [ "--intro-image", "Front page banner", "Shown behind the game's name at the top of the front page." ]
  }.freeze

  included do
    PICTURES.each_key do |picture|
      has_one_attached picture
      attribute :"remove_#{picture}", :boolean, default: false
      after_save { send(picture).purge_later if send(:"remove_#{picture}") && send(picture).attached? }
    end
    validate :pictures_are_reasonable

    before_create { apply_preset(DEFAULT_PRESET) }
    normalizes :font_body, :font_heading, with: ->(f) { f.squish.presence }
    normalizes :custom_css, with: ->(css) { css.presence }
    validates :font_body, :font_heading, length: { maximum: 200 }, format: { with: FONT_FORMAT, message: "can only have letters, numbers, spaces, commas, hyphens and quotes" }, allow_nil: true
    validates :custom_css, length: { maximum: 50_000 }
    validate :skin_colours_are_colours
    validate :font_quotes_are_closed
  end

  # The form sends every colour; only the ones that differ from the
  # built-in value are kept, so later changes to the defaults still apply.
  def skin_colours=(values)
    super(changed_colours(values, 1))
  end

  def skin_dark_colours=(values)
    super(changed_colours(values, 2))
  end

  def colour(key, dark: false)
    (dark ? skin_dark_colours : skin_colours)[key] || COLOURS.fetch(key)[dark ? 2 : 1]
  end

  def apply_preset(key)
    preset = PRESETS.fetch(key)
    # A look with its own text font sets it; leaving that look puts the
    # game's own text font back to the built-in one.
    if preset.key?(:font_body)
      self.font_body = preset[:font_body]
    elsif skin_base && font_body == PRESETS.dig(skin_base, :font_body)
      self.font_body = nil
    end
    self.skin_base = key
    self.skin_colours = preset[:colours]
    self.skin_dark_colours = preset[:dark_colours] || {}
    self.skin_dark_mode = preset[:dark_mode]
    self.font_heading = preset[:font_heading]
  end

  # Which ready-made look the colours match, if any.
  def current_preset
    PRESETS.find { |_, preset| changed_colours(preset[:colours], 1) == skin_colours && changed_colours(preset[:dark_colours] || {}, 2) == skin_dark_colours &&
      preset[:dark_mode] == skin_dark_mode? && preset[:font_heading] == font_heading && (!preset.key?(:font_body) || preset[:font_body] == font_body) }&.first
  end

  def skinned?
    PICTURES.keys.any? { |picture| send(picture).attached? } || skin_colours.any? || skin_dark_colours.any? || !skin_dark_mode? || font_body || font_heading || custom_css
  end

  # The stylesheet itself. Every value in it has been checked above, except
  # the extra CSS, which only Wellkeepers can write.
  def skin_css
    # @import (for web fonts) only works at the very top of a stylesheet.
    imports = custom_css.to_s.scan(/^[ \t]*@import[^;\n]*;[ \t]*$/)
    lines = [ "/* This game's skin, set in Admin, Look */", *imports.map(&:strip), ":root {" ]
    COLOURS.each_key { |key| lines << "  --color-#{key}: #{colour(key)};" if skin_colours[key] }
    lines << "  --font-body: #{font_body};" << "  --font-ui: #{font_body};" if font_body
    lines << "  --font-heading: #{font_heading};" if font_heading
    PICTURES.each do |picture, (variable, _label, _hint)|
      file = send(picture)
      lines << "  #{variable}: url(\"#{Rails.application.routes.url_helpers.rails_blob_path(file, only_path: true)}\");" if file.attached?
    end
    lines << "}"
    dark = skin_dark_mode? ? COLOURS.keys.select { |key| skin_dark_colours[key] } : COLOURS.keys
    if dark.any?
      lines << "@media (prefers-color-scheme: dark) {" << "  :root {"
      dark.each { |key| lines << "    --color-#{key}: #{colour(key, dark: skin_dark_mode?)};" }
      lines << "  }" << "}"
    end
    lines << ":root { color-scheme: light; }" unless skin_dark_mode?
    lines << "" << imports.reduce(custom_css) { |css, line| css.sub(line, "") }.strip if custom_css
    lines.join("\n") + "\n"
  end

  private
    def pictures_are_reasonable
      PICTURES.each_key do |picture|
        file = send(picture)
        next unless file.attached? && attachment_changes[picture]
        errors.add(picture, "must be a picture (PNG, JPEG, GIF or WebP)") unless file.content_type.in?(%w[ image/png image/jpeg image/gif image/webp ])
        errors.add(picture, "must be smaller than 5 MB") if file.blob.byte_size > DescribedWithImage::MAX_IMAGE_SIZE
      end
    end

    def changed_colours(values, index)
      values.to_h.to_h { |key, value| [ key.to_s, value.to_s.strip.downcase ] }
        .select { |key, value| COLOURS.key?(key) && value != COLOURS[key][index] }
    end

    def font_quotes_are_closed
      %i[ font_body font_heading ].each do |field|
        value = self[field].to_s
        errors.add(field, "has a quote mark that isn't closed") if value.count("'").odd? || value.count('"').odd?
      end
    end

    def skin_colours_are_colours
      (skin_colours.values + skin_dark_colours.values).each do |value|
        next if value.to_s.match?(COLOUR_FORMAT)
        errors.add(:base, "Colours must look like #5b3f8c")
        break
      end
    end
end
