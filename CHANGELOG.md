# Changelog

Short, plain-language notes on what changed. Newest first.

## 2026-10-14 — Step 3: Logs and safety

- Players can finish a Chapter (and undo it for a day). Idle Chapters are
  finished by the game after a month.
- Finished Chapters go into the Archives as Manuscripts, which you can filter
  by Setting or character. Hidden ones need everyone's agreement first.
- Players can report a Passage or Chapter. Staff can then read it, hide a
  Passage, lock the Chapter, warn the player, or ban an account or address.
  Games can block known VPNs.
- A new Notifications page lets players pick activity emails (with the missed
  Passages included) and browser pop-ups. Every email has a "stop these
  emails" link.
- "Forgot your password?" on the log-in page emails a reset link.
- Chapters have OOC lines, narration and NPC Passages as well as ordinary
  Passages. OOC lines don't take a turn and stay out of the Manuscript.
- Guests can chat in the OOC Chat without logging in, with spam protection.
- Arial is now the default font, in emails too.
- The OOC Chat has its new name, a coloured header bar and a tiny icon by
  each player. Chapters and the Where list show each Setting's Area names.

## 2026-10-14 — Step 2: Chapters

- Characters can start Chapters in the Setting they're standing in, and join
  or leave them. Chapters can be Open, Private (invite only) or Hidden.
- Passages appear live, with the character's icon and name. Clicking either
  opens a small profile. You can edit or remove your own Passages.
- Turns: take turns, free-for-all, or the 3-Passage rule. Pass your turn,
  storytellers can skip someone, and players who go quiet get a warning and
  are skipped after a few minutes unless they click "I'm here!".
- Characters can upload an icon.
- Your Chapters show as tabs on every page, with unread counts. The browser
  tab shows a count and the site icon gets a dot when something's new.
- Moving between Settings adds arrival and departure lines to Chapters there.
- A Where page (in the Menu) shows where everyone is. Front-page boards show
  their latest open Chapter.

## 2026-10-14 — Step 1b: Step 1 changes

- Players now see themed words: Setting (room), Path (exit), Area, and later
  Chapter, Passage, Manuscript and Archives. They all live in one file,
  `config/locales/en.yml`.
- The front page lists the game's Areas like forum boards. Areas can sit
  inside other Areas, and each Setting belongs to one.
- Areas and Settings can have an image, a description, or both.
- Extras (all Settings, OOC chat, admin panel) moved into a Menu.
- The OOC chat can fold into the right edge and slide back out. Each browser
  remembers whether you left it open.
- While the OOC chat is folded, its tab shows how many new messages you
  haven't seen.
- Sign-up has a box to opt in to email notifications. The emails themselves
  arrive in step 3; the choice is saved now.
- One player name for logging in and for the OOC chat. Accounts now have an
  email address, required unless the game turns that off.
- Character names can use spaces and special characters.
- Building a Path can add the return Path at the same time.
- A game with no Settings gets a default starting Setting.
- The front page shows each top-level Area as a banner, with the Areas inside
  it as boards. Opening a board takes you to its entrance Setting, and an
  arrow beside its name lists shortcuts inside.
- "Travel here" moves your character straight to a Setting you're looking at.
- The admin panel has its own tabs.
- Staff levels (Page, Scribe, Wellkeeper), the Founder flag, Page jobs and the
  Storyteller flag, set from a new admin panel. Wellkeepers can delete
  characters and change game settings.

## 2026-10-14 — Project tracking

- Added a decisions log, roadmap, task board and a guide for handing small
  tasks to other AIs (`AGENTS.md`, `docs/`, `tasks/`).
- Added the settled answers on SOUL, Inklings, Grimoire, hidden-scene access
  and hosting to `docs/design.md`.
- Fixed the automatic system-test check, which failed because the
  `test/system` folder was missing.

## 2026-10-14 — Step 1: Foundation

- Created the Rails 8.1 app (Hotwire + PostgreSQL). Stack confirmed by the owner.
- Moved the planning handoff into `docs/design.md`.
- Accounts: sign up and log in with a username and password. Each account also
  has a player name shown in OOC chat.
- Characters: create and edit characters; a "Playing as" dropdown in the header
  switches the active character.
- The game remembers which character you last used in each room and switches
  back to it when you return.
- Rooms and exits: click an exit to move your active character. The list of who
  is in a room updates live.
- Site-wide OOC chat in a side panel (and on its own page), updating live.
- Staff building tools: create/edit rooms and add/remove exits.
- Placeholder rooms in `db/seeds.rb`.
