# Changelog

Short, plain-language notes on what changed. Newest first.

## 2026-10-14 — New starting map

- A fresh game now starts with three Areas, City, Country and Forest,
  each holding three smaller Areas (Uptown, Midtown and Downtown; The
  Village, Farmland and Riverside; Forest's Edge, Deep Woods and
  Lakeshore). Each small Area has two described Settings, all joined by
  Paths, and the three big Areas link to each other. New characters
  start in Central Square. Everything can be edited or replaced from
  the admin panel.

## 2026-10-14 — Storyteller tools

- A Chapter's Storyteller can call for rolls from players, see the
  players' Aspects and Skills, and suggest XP that staff approve.

## 2026-10-14 — Default look

- New games start in Slate blue and gold, and the admin panel asks the
  admin to pick a look (plain and the others are one click away).

## 2026-10-14 — Roster options

- Games choose how roster characters change hands: claim and play
  straight away, answer some questions again, or redo the whole
  application.
- Fixed: changing a profile answer that was already filled in didn't save.

## 2026-10-14 — Step 10: Platform

- Admin → Features: switch SOUL, Inklings, Grimoire, the wiki and guest
  chat on or off in one place.
- Admin → Look: pick the game's colours (light and dark), fonts and extra
  CSS, or start from one of three ready-made looks.

## 2026-10-14 — Step 9b: Wiki

- A wiki in the Menu for rules, lore and plots. Anyone with an account can
  write pages in Markdown, link them with [[Page name]], and pull in live
  lists of characters, Manuscripts, Settings and pages. Every change is
  kept, staff can lock pages, and staff can list pages in the Menu.

## 2026-10-14 — Step 9: Grimoire

- Magic, for games that switch it on: branches tied to SOUL Skills, spells
  learned with XP and cast in Chapters as rolls, and spell proposals that
  staff approve.

## 2026-10-14 — Step 8: Inklings

- Inklings: threads about a character (goals, secrets, requests, hints)
  that players build up, share and send to staff. Staff approve them, ask
  for changes, add staff notes and grant rewards through SOUL.

## 2026-10-14 — Step 7: Game time

- Each Chapter has its own in-character date and time of day, which its
  players can move forward. The Chapter notes each change.
- The front page shows the game's date, today's weather and who's online.

## 2026-10-14 — Step 6c: Ideas from Jcink boards

- An alerts bell in the header for new Passages, your turn, @mentions and
  finished Chapters.
- "My Chapters" in the Menu lists each character's open Chapters, whose
  turn it is and who posted last.
- Chapters can have a subtitle and labels such as content warnings.
- Character groups (houses, factions) colour their characters' names, and
  games can show chosen profile fields beside Passages.

## 2026-10-14 — Step 6b: Rosters

- A roster of characters other players can apply to take over. Staff pick
  who gets each one, and the new player gets everything in character.
- Players can tick "put on the roster if they go idle", or ask staff to put
  a character on the roster now. Staff can also add new characters to it.
- A character directory in the Menu lists everyone being played and the
  roster, and can be filtered by public profile fields.
- Accounts are archived instead of deleted. A Founder can delete an account
  that never had characters.

## 2026-10-14 — Step 6: SOUL extras

- Boons and Banes: staff keep a catalogue, players pick theirs on a starting
  sheet or ask staff later, and they change rolls of the Skills they're tied to.
- Players can ask a Chapter's Storyteller to judge a roll.
- Culminations: players propose milestones and staff approve them.
- Each character has a Narrative History, and staff have a log of every
  staff change.

## 2026-10-14 — Security rules

- New passwords need 10 characters, with a number, a capital and a
  lower-case letter.
- Picture uploads are limited to 20 an hour, and 50 gallery pictures across
  all of one player's characters.
- Anyone who keeps hitting the posting limits is muted for 10 minutes. Staff
  can lift it from Players and staff.

## 2026-10-14 — Retiring characters and faster cloud sessions

- Characters are no longer deleted. Wellkeepers retire them instead, and
  their Passages and Manuscripts stay, greyed out.
- New cloud sessions now start the database, install gems and set up the
  databases automatically.

## 2026-10-14 — Step 5: SOUL basics

- Characters have a SOUL tab: Resonance, Aspects and Skills. Players set a
  starting sheet with points, and it locks at approval.
- XP arrives every week and from finished Chapters. Players spend it to
  raise ratings, and staff can give or take XP.
- A "Roll a Skill" box in Chapters rolls 2d20 plus the Skill and posts the
  result for everyone.
- Wellkeepers set the game's Aspects and Skills under SOUL in the admin panel.

## 2026-10-14 — Step 4: Profiles and approval

- Character profiles have tabs: Profile, Application, Gallery, Relationships
  and Manuscripts. Staff choose the profile questions and whether each is
  public or private.
- Ages are worked out from a character's birthday and the game's own date,
  which staff set in Game settings.
- Games can require staff approval. New characters are drafts until a
  player submits them and staff approve; until then they can explore but
  not join Chapters.
- Players have their own profile with an icon and About me.

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
- Messages: out-of-character conversations between players, one-to-one or in
  groups. Message a character's player without learning who they are. New
  messages show in the header, by email and as browser pop-ups.
- A Chapter's Setting box shows the Paths out. Settings can be saved to My
  places for one-click travel, and the Where list shows idle times.
- Security fixes: switched off an upload address that could fill the disk,
  forced HTTPS on the live site, required your password to change your email,
  made hidden Chapters need everyone's agreement to go public, blocked edits
  after a Chapter is finished or locked, limited how wide IP bans can be (and
  kept them off senior staff), added posting speed limits, and set an
  8-character minimum for passwords.
- Every part of every page has a CSS class for skins, listed in
  `docs/css-classes.md`.
- Players can pause a Chapter, with a note saying when they'll be back.
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
