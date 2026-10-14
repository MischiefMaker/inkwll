# Changelog

Short, plain-language notes on what changed. Newest first.

## 2026-10-14 — Step 1b: Step 1 changes

- Players now see themed words: Setting (room), Path (exit), Area, and later
  Chapter, Passage, Manuscript and Archives. They all live in one file,
  `config/locales/en.yml`.
- The front page lists the game's Areas like forum boards. Areas can sit
  inside other Areas, and each Setting belongs to one.
- Areas and Settings can have an image, a description, or both.
- Extras (all Settings, OOC chat, admin panel) moved into a Menu.
- One player name for logging in and for the OOC chat. Accounts now have an
  email address, required unless the game turns that off.
- Character names can use spaces and special characters.
- Building a Path can add the return Path at the same time.
- A game with no Settings gets a default starting Setting.
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
