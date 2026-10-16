# World packs

A world pack is a whole game world in one file, for setting up a Well from an
old game without building it by hand. The Founder uploads it in
**Admin → Import a world**, sees every change first, then presses Import.
From the command line the same thing is:

    bin/rails "inkwll:import_world[path/to/pack.world.json,FounderName]"
    bin/rails "inkwll:import_world[path/to/pack.world.json,FounderName,remove]"

## What importing does

- Everything is matched by name, so importing the same pack twice changes
  nothing the second time. Areas match by name, Places by name and Area,
  Paths by the Place they leave from and their name, wiki pages by title and
  boards by name (or by `was`, which renames an existing board).
- It only adds and updates, unless **Also remove what isn't in the pack** is
  ticked. Then Areas, Places and Paths the pack leaves out are removed, except
  The Prologue, any Place with Chapters in it (so no story is lost), and the
  Areas that still hold those. Characters in a Place that is removed are moved
  to The Prologue first. Wiki pages, boards, players and characters are never
  removed.
- The Prologue gets a Path to the entrance of each top-level Area in the pack.
- It all happens in one go: if anything fails, nothing changes.

## The file

JSON, up to 25 MB, with pictures inside it as base64. Every key is optional
except `format`.

```json
{
  "format": "inkwll-world-pack",
  "name": "Last Call of the Wild",
  "game": { "name": "…", "blurb": "…", "icon": "icon" },
  "look": {
    "preset": "…", "colours": { "bg": "#405570" }, "dark_colours": {}, "dark_mode": false,
    "font_body": "Oswald, sans-serif", "font_heading": "'Amatic SC', serif",
    "custom_css": "…", "pictures": { "intro_banner": "banner" }
  },
  "areas": [ { "name": "Hogwarts", "parent": null, "summary": "…", "description": "…",
               "position": 1, "entrance": "Castle Foyer", "icon": "icon", "image": "background", "background": null } ],
  "places": [ { "name": "Castle Foyer", "area": "Hogwarts", "kind": "building",
                "summary": "…", "description": "…", "icon": null, "image": null, "background": null } ],
  "paths": [ { "from": "Castle Foyer", "to": "Great Hall", "name": "Great Hall",
               "kind": "building", "direction": "OUT", "number": null } ],
  "wiki_pages": [ { "title": "Rules", "body": "Markdown…", "tags": ["lore"], "menu_position": 2, "locked": true } ],
  "boards": [ { "name": "Newest News", "was": "News", "description": "…", "position": 1,
                "who_can_start": "staff", "who_can_reply": "nobody", "icon": null, "image": null } ],
  "images": { "icon": { "content_type": "image/jpeg", "filename": "icon.jpg", "data": "base64…" } }
}
```

- Pictures are named by their key in `images`. PNG, JPEG, GIF or WebP, 5 MB
  each at most. `look.pictures` uses the Look picture names
  (`page_background`, `box_background`, `intro_banner`).
- A Path's `name` defaults to the Place it goes to (40 characters at most).
- Areas nest by naming their `parent`, which can be in the pack or already in
  the game.

Packs are made by a script from an old game's files. The one for Last Call of
the Wild lives in the private mush-archives repository, under
`games/last-call-of-the-wild/inkwll-pack/` (`build.py` writes the file).
