# Inkwll's built-in icons: simple line drawings, drawn inline as SVG like the
# header's bell, so they take the colour of the text around them. Each is a
# 24×24 drawing made of the shapes below.
module IconsHelper
  ICONS = {
    home: '<path d="M3 11 12 3l9 8"/><path d="M5 10v10h5v-6h4v6h5V10"/>',
    character: '<circle cx="12" cy="8" r="4"/><path d="M4 21c0-4 4-7 8-7s8 3 8 7"/>',
    characters: '<circle cx="9" cy="8" r="3.5"/><path d="M2 20c0-3.5 3-6 7-6s7 2.5 7 6"/><path d="M16 4.5a3.5 3.5 0 0 1 0 7"/><path d="M18 14c2.5.6 4 2.8 4 6"/>',
    messages: '<rect x="3" y="5" width="18" height="14" rx="2"/><path d="m3 7 9 6 9-6"/>',
    bell: '<path d="M6 8a6 6 0 0 1 12 0c0 7 3 9 3 9H3s3-2 3-9"/><path d="M10.3 21a1.94 1.94 0 0 0 3.4 0"/>',
    menu: '<path d="M4 6h16"/><path d="M4 12h16"/><path d="M4 18h16"/>',
    guide: '<path d="M12 7v14"/><path d="M3 5h6a3 3 0 0 1 3 3 3 3 0 0 1 3-3h6v13h-6a3 3 0 0 0-3 3 3 3 0 0 0-3-3H3z"/>',
    door: '<path d="M6 21V4a1 1 0 0 1 1-1h10a1 1 0 0 1 1 1v17"/><path d="M3 21h18"/><path d="M14 12h.01"/>',
    pin: '<path d="M12 21s-7-6.2-7-12a7 7 0 0 1 14 0c0 5.8-7 12-7 12z"/><circle cx="12" cy="9" r="2.5"/>',
    quill: '<path d="M20 3C12 4 7 9 5 19"/><path d="M20 3c-1 6-5 10-11 11"/><path d="M4 21l1-2"/>',
    inkwell: '<path d="M9 3h6"/><path d="M10 3v4c-4 .7-6 3-6 6v6a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2v-6c0-3-2-5.3-6-6V3"/><path d="M4 15h16"/>',
    bookmark: '<path d="M6 3h12v18l-6-4-6 4z"/>',
    archive: '<rect x="3" y="4" width="18" height="4" rx="1"/><path d="M5 8v11a1 1 0 0 0 1 1h12a1 1 0 0 0 1-1V8"/><path d="M10 12h4"/>',
    roster: '<rect x="5" y="4" width="14" height="17" rx="2"/><path d="M9 4V3h6v1"/><path d="M9 10h6"/><path d="M9 14h6"/><path d="M9 18h3"/>',
    board: '<path d="M4 4h16v12H9l-5 4z"/><path d="M8 8h8"/><path d="M8 12h5"/>',
    wiki: '<path d="M5 4a1 1 0 0 1 1-1h13v15H6a1 1 0 0 0-1 1z"/><path d="M5 19a2 2 0 0 0 2 2h12v-3"/><path d="M9 7h6"/>',
    chat: '<path d="M3 5h12v9H8l-5 4z"/><path d="M15 9h6v9l-4-3h-6v-1"/>',
    profile: '<rect x="3" y="4" width="18" height="16" rx="2"/><circle cx="9" cy="11" r="2.5"/><path d="M5 17c.5-2 2-3 4-3s3.5 1 4 3"/><path d="M15 10h3"/><path d="M15 14h3"/>',
    shield: '<path d="M12 3 4 6v6c0 5 3.5 8 8 9 4.5-1 8-4 8-9V6z"/>',
    compass: '<circle cx="12" cy="12" r="9"/><path d="m15.5 8.5-2 5-5 2 2-5z"/>'
  }.freeze

  # icon(:home) draws the house icon. Pass css: to add classes after the
  # "icon icon--home" ones, and size: for its width and height in pixels.
  def icon(name, size: 18, css: nil)
    drawing = ICONS.fetch(name.to_sym)
    classes = [ "icon", "icon--#{name.to_s.dasherize}", css ].compact.join(" ")
    tag.svg(drawing.html_safe, class: classes, viewBox: "0 0 24 24", width: size, height: size, "aria-hidden": "true",
      fill: "none", stroke: "currentColor", "stroke-width": "2", "stroke-linecap": "round", "stroke-linejoin": "round")
  end

  # A place's own icon picture if it has one, or a drawn icon in a small tile
  # so every Area, Setting and board has something there by default.
  def place_icon(record, default, css:)
    if record.icon.attached?
      image_tag record.icon, alt: "", class: css
    else
      tag.span(icon(default, size: 20), class: "#{css} icon-tile icon-tile--#{default}")
    end
  end
end
