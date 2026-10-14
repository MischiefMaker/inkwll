# Changelog

Short, plain-language notes on what changed. Newest first.

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
