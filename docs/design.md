# Inkwll design

This document records what has been decided, what is only proposed, and what is
still open. It started as the planning handoff and is kept up to date as
decisions are made.

**Status key:** **[Decided]** came from the project owner. **[Proposed]** is a
suggestion that still needs the owner's confirmation; don't treat it as settled.

## 1. Concept

**Guiding principle [Decided]:** keep forum RP's easy navigation and many
Chapters at once, but make the grid feel real and physical, like moving
through space on a traditional MU. When the two pull apart, protect the
feeling of physical space.

Players see themed words: a room is a **Setting**, an exit is a **Path**, a
scene is a **Chapter**, a pose is a **Passage**, and finished logs are
**Manuscripts** in the **Archives**. This document and the code use the plain
words.

Look and feel: the owner's earlier forum skins are in `docs/design-references/`,
with the patterns they share. Use them when shaping the front page, Area
listings and the default skin.

Layout [Decided]: the roleplay is front and centre, laid out more like a
forum than AresMUSH. Rules, plots and other extras live in the menu.
Updated 2026-10-14: less like a forum. The front page shows the game's name
and blurb, then the top-level Areas, each with an Enter button; shortcuts to
single Settings are tucked away so players get around by Paths.

A web-only (no telnet) roleplaying game that combines forum RP and MUSH.
Inspired by AresMUSH, but web-first.

- The world is organized into **rooms**: in-character spaces players move
  through by clicking links (**exits**).
- Each room can hold multiple concurrent live chats (**scenes**). Chats are
  either joinable or private.
- Chats persist and can be resumed later (forum-RP feel) while also being
  real-time.
- Finished chats become **logs** attached to both the room and the
  participating characters.

## 2. Owner context

- Comfortable with HTML/CSS. Not an experienced programmer. Relies heavily on
  AI-assisted coding.
- Wants a stack that is beginner-friendly but supports future growth:
  skins/themes, plugins, and turning features on and off.
- Prefers small, targeted changes. Explain what is changing and why in plain
  language, and do not redesign things unprompted.

## 3. Decisions

Each decision also has a dated entry in [`decisions.md`](decisions.md).

### Stack and hosting [Decided]

- Ruby on Rails 8 + Hotwire (Turbo + Stimulus) + PostgreSQL.
- Built and tested in the cloud (Claude Code on the web, GitHub Actions CI).
- Hosted on a single DigitalOcean droplet that runs the Rails app and
  PostgreSQL together, deployed with Kamal (included with Rails 8). Avoid
  adding Redis or other services that would need extra hosting. Building and
  testing stays in the cloud until launch.

### Accounts and characters [Decided]

- One player account (player name and password). Characters are sub-accounts with no
  separate login.
- A dropdown switches the active character.
- The app remembers which character the player last used in each room and each
  scene, and applies it automatically.
- Accounts need an email address by default, used for password reset links.
  Each game can make it optional; without one, staff reset the password.
- Staff has three levels: Wellkeepers (top), Scribes (admin), and Pages with
  job flags (such as Build Page and App Page). Only Wellkeepers with the
  Founder flag can make new Wellkeepers. Storyteller is a flag on a player, below staff. Only flagged
  players or staff can be a scene's storyteller. Storytellers get some SOUL and
  Inklings tools but never other players' secret details. See `decisions.md`.
- Lurkers can watch joinable scenes without posing.
- Every character has a profile: game-configured profile and application
  fields, plus SOUL, Grimoire and Inklings sections when those are on. By
  default it has Demographics (age worked out from the birthday by the IC
  clock), an Application tab, a gallery, relationships and public logs.
  Players have a simpler profile; see "Profile layout" in `decisions.md`.
- Character approval is a per-game setting. When it is on, new characters
  cannot pose in scenes until staff approve them. They can still explore.
  See "Step 4 details picked while building" in `decisions.md`.

### Presence [Decided]

- A character is always in exactly one room.
- A character can be in multiple chats at once.
- Chat state must stay consistent across all of a character's open chats.

### Chat visibility [Decided]

Two switches, *private* and *hidden*:

- **Joinable** (default): visible in the room, anyone can join without an
  invite.
- **Private**: others can see that it exists and who is in it, but cannot join
  without an invite. When closed, its log is added to the room and character
  logs.
- **Hidden**: visible only to its players (and possibly admin; see open
  questions). When closed, the log is visible only to the players, unless all
  players agree to make it public.

Hidden implies private, so turning hidden on must force private on. There are
effectively three states.

One player alone can make a chat more closed, but not more open: a private or
hidden chat only opens up once every player agrees (2026-10-14).

### Logs [Decided]

- Finished chats remain attached to the room and linked to each participating
  character, so logs can be viewed from both places.
- The public/private/hidden rules above determine who can read them.

### Moderation and reporting [Decided]

- Built-in reporting tools.
- Admins cannot browse hidden scenes. A report on a hidden or private scene
  gives staff access to that one scene's log, and nothing more.
- This must be stated clearly in the UI when a chat is set private/hidden and in
  the report form.

### Pose order, configurable per chat [Decided]

- Turn-based (default)
- Free-for-all
- 3-pose rule: you must wait for three other poses before posing again.

### Game time [Decided]

- The game keeps a configurable IC clock with an offset and a ratio (example:
  500 years ago, 3 IC days per 1 OOC day).
- Each chat can override its date/time.
- Within a chat, IC time passes only at the speed of the scene. The date stays
  as started unless the players agree to move it forward.

### Email notifications [Decided]

- Players can opt in to emails about new activity: every time, only when they
  aren't logged in, or only after they've been away for some days they choose.
  Players can also choose to be emailed only when it's their turn, in
  Chapters with more than two players.
  Off by default. Emails include the text of the missed Passages, from
  Chapters the player can already read. Details in `decisions.md`. Built in
  step 3.

### Browser alerts [Decided]

- The tab title shows a count and the favicon gets a dot when there's
  something new (step 2). Players can turn on optional browser notifications
  (step 3): for all activity, only on their turn, or only after something
  has sat unread for some minutes. Details in `decisions.md`.

### OOC chat [Decided]

- One persistent OOC chat, using player names (not character names), visible
  site-wide like a forum Cbox.

### Core systems: SOUL, Inklings, Grimoire [Decided]

SOUL, Inklings and Grimoire are the default systems. Each one is rebuilt for
Inkwll, not ported from AresMUSH. Each can be switched on or off through the
feature toggles, and the design leaves room for alternative plugins later.

- **SOUL** is the backbone of the stats and character system. It replaces FS3
  and covers configurable Aspects and Skills, optional Resonance (locked at
  approval), an XP ledger, Boons and Banes, open-ended 2d20 rolls (including
  GM-assisted rolls), Culminations, and a player-facing Narrative History with
  a separate staff audit trail.
  Reference: github.com/MischiefMaker/ares-soul-plugin
- **Inklings** supports roleplay: threaded requests, plot tracking and
  storyteller tools. Approved Inkling outcomes (XP, Boon/Bane progress,
  Culminations) apply through SOUL.
  Reference: github.com/MischiefMaker/ares-inklings-plugin
- **Grimoire** supports magic, for games that need it. It has configurable
  branches, each tied to a skill. Players learn spells with XP, cast them as
  rolls in a scene, and propose new spells for staff approval.
  Reference: github.com/MischiefMaker/ares-grimoire-plugin

How they plug in [Proposed, owner agreed in principle]:

- A SOUL roll is a Pose type ("roll") inside a scene. GM-assisted rolls use the
  scene's storyteller role. (Built in step 5; GM-assisted rolls in step 6; calling rolls, seeing
  players' Aspects and Skills, and suggesting XP for staff approval in step 8.)
- Finishing a scene awards SOUL XP to its approved participants who posted in
  it. (Built in step 5; see "Step 5 details" in `decisions.md`.)
- Grimoire spells use SOUL skills, and casting a spell is a SOUL roll.
- The rest of the app talks to "the character system" through a small
  interface, so SOUL could be swapped out. Grimoire and Inklings must work
  correctly when they are disabled.
- Following the extensibility proposal, start with the `features` table, and
  do not build a plugin system first.

### CSS classes for skinning [Decided]

- Every element has a meaningful CSS class (`block`, `block__part`,
  `block--kind`, in plain words), and each page's `<body>` has page classes,
  so games can restyle anything. The reference for skinners is
  `docs/css-classes.md`.

## 4. Proposals (confirm before relying on them)

### Extensibility [Proposed]

- Start with a `features` settings table. Each module checks whether it is
  enabled.
- [Decided] Skins via CSS variables and extra CSS set in the admin panel;
  swappable view folders later if needed. (The stylesheet already
  keeps colours and fonts in CSS variables; nothing else is built yet.)
- Package modules as Rails engines later, once real plugin needs are known. Do
  not build a plugin system first.

### Who plays which character [Decided]

- A game setting decides whether a character's player is shown to everyone
  or only to staff. With staff-only, players can still send a Message "to
  the player of [character]" without learning who that is, and replies come
  back as "the player of" that character. New games start
  with players hidden. See `decisions.md`.
- As built so far, nothing shows who plays a character: profiles,
  mini-profiles and Chapters only show character names.

### Data model (draft) [Proposed]

Items built in step 1 are marked ✅.

- ✅ Account: login, display name (OOC identity), active character.
- ✅ Character: belongs to an account.
- ✅ Room, Exit: description, links. [Decided] Rooms belong to nestable Areas (not built yet); characters are
  only ever in a room, never in an Area.
- Scene: room, visibility, hidden flag, pose mode, status
  (active/idle/finished), optional IC date override, frozen-date flag.
- SceneParticipant: character, scene, role (player/storyteller/lurker),
  last-read marker.
- Pose: scene, character, body, type (pose/say/OOC/narration/roll),
  server-assigned sequence number.
- Report, LogShare: report records, plus each player's consent to make a hidden
  log public.
- ✅ OocMessage: account-level, site-wide.
- GameClock: epoch offset and ratio.
- ✅ Per-room (and later per-scene) "last used character" records:
  `RememberedCharacter`, which works for any kind of place.

### Technical rules [Proposed]

- The server assigns pose sequence numbers (inside a database transaction) and
  tracks whose turn it is. The browser never decides whose turn it is.
- [Decided] Turn-based mode: players can pass, storytellers can skip, and
  auto-skip (on by default, can be turned off) warns a player 5 minutes after
  the previous pose and skips them 2 minutes later unless they click
  "I'm here!". Posting out of turn shows a warning with a "Post anyway"
  button.
- [Decided] Any player can finish a scene (24-hour undo). Scenes go idle after
  7 days without a pose and finish on their own after 30 (game settings).
- [Decided] On a report, staff can read, lock the scene, hide a pose (original
  kept) and warn the player.
- [Decided] Players can edit their own poses until the scene finishes; edited
  poses are marked, and staff can see the original.
- [Decided] The 3-pose rule is only available in scenes with four or more
  players.
- IC time: `ic_now = epoch + (real_now - anchor) * ratio`. A scene override
  stores its own date and changes only through a "propose time skip" that the
  other players accept.
- Staff cannot browse hidden scenes. A report grants access to that one scene.

## 5. Roadmap

The build order and the current step are kept in [`roadmap.md`](roadmap.md).

## 6. How the built steps work

Players see themed words (Setting, Path, Area and so on); the code uses plain
words, and `config/locales/en.yml` maps one to the other.

- **One player name.** Players sign up with a player name (letters, numbers,
  underscores) that is shown in the OOC chat and also used to log in,
  ignoring capitals.
- **Email.** Required at sign-up unless a Wellkeeper turns it off in Game
  settings. Password reset emails come in the Going live step; until then
  staff reset passwords by hand.
- **Characters.** Names are unique across the game (ignoring capitals) and may
  use spaces and special characters. Characters are never deleted: Wellkeepers
  retire them from the admin panel, and logs still show them, greyed out.
  Deleting a player account keeps that player's characters.
- **Areas.** Every room belongs to an Area, and Areas can nest. The front page
  lists the top-level Areas, each with an Enter button that takes the
  character to the Area's entrance room; shortcuts to single rooms sit in a
  small "Shortcuts" fold. Areas and rooms can each have any of: a small icon,
  a large banner, a page background, short text and long text.
- **Starting room.** A builder ticks "New characters start here" on one room.
  If none is ticked, the oldest room is used, and a game with no rooms makes
  a default one.
- **Exits are one-way**, but the exit form can add the return exit at the
  same time.
- **Looking vs. being there.** Anyone can open any room page to look at it.
  Exit buttons only work when the active character is in that room.
- **Remembered character rule.** When you open a room page: if the character
  you last used there is still in that room, it becomes active automatically;
  otherwise, if your active character is in that room, it is remembered for
  next time. Switching with the dropdown or walking through an exit also
  updates the memory.
- **Live updates.** The room page updates its "Here" list live when someone
  enters or leaves. OOC messages appear live for everyone, and the OOC panel
  stays put while you move between pages.
- **Staff.** Accounts have a staff level (Page, Scribe, Wellkeeper), a Founder
  flag, Page job flags (Build, App) and a Storyteller flag. The admin panel
  (Menu → Admin panel) shows each staff member only the sections their level
  allows. The first Founder is made on the server with
  `bin/rails "inkwll:make_founder[PlayerName]"`.

### Step 2: Chapters

- **Starting.** A Setting's page lists its Chapters (busiest first, idle ones
  last) and has "Start a chapter here" when your active character stands
  there. A Chapter is Open, Private or Hidden, and uses one of three turn
  modes. Flagged Storytellers and staff can start as the storyteller, or take
  or drop the role later.
- **Joining.** Anyone can watch an Open Chapter. Joining walks your character
  to the Chapter's Setting first ("Travel here and join"). Private and Hidden
  Chapters need an invitation, which any character in them can send by name.
  Only invited characters can read them.
- **Passages** are numbered by the server, appear live, and show the
  character's icon and name. Clicking either opens a mini-profile. Players
  can edit (marked "edited", original kept) or remove ("Passage removed")
  their own Passages.
- **Kinds of post.** Besides Passages, players can post an NPC's Passage
  (takes their turn), narration (Storyteller, or anyone without one; no
  turn) and OOC lines (no turn, not unread, left out of the Manuscript).
- **Pausing.** Any player can pause a Chapter with an optional "back on"
  note. That stops the turn timer and the auto-finish; a new Passage or
  "Pick it back up" resumes it.
- **Turns.** Turn order is the order people joined. The first Passage can come
  from anyone. Posting out of turn asks "Post anyway" first and doesn't move
  the turn. Pass, storyteller Skip, and auto-skip (warning after the
  Chapter's minutes, skip two minutes later unless "I'm here!") are run by
  the server, with a background job for the timer. The 3-Passage rule works
  like turns until there are four characters.
- **Moving.** Walking or travelling adds "X leaves for …" and "X arrives from
  …" lines to the non-idle Chapters in both Settings.
- **Tabs and unread.** Every page shows the player's Chapters as tabs with
  their Setting, unread count and "Your turn". The page tells the server what
  has been read only while it is visible, so the browser tab can show "(3)"
  and a dot on the site icon for Passages that arrived while you were away.
- **Where** (in the Menu) lists every character by Setting, with the Open
  Chapters they're in. Front-page boards show their latest Open Chapter.
  Private and Hidden Chapters never appear in either.
- **Character icons** are uploaded on the character's edit page. Without one,
  the character's initial is shown.

### Step 3: Logs and safety

- **Finishing.** Any player can finish a Chapter; the others can undo it for
  24 hours. Idle Chapters are finished by the game after the game's
  auto-finish days. Finished Chapters are read-only Manuscripts.
- **Archives** (in the Menu) list finished Manuscripts, filtered by Setting or
  character. Open and Private ones are listed; Hidden ones only after every
  player has agreed on the Chapter's page.
- **Reporting.** Any Passage or Chapter can be reported. Scribes and
  Wellkeepers see reports in the admin panel and can then read that one
  Chapter, hide a Passage, lock the Chapter, warn the player or ban them.
- **Bans** cover an account, an IP address or a range, for a time or until
  lifted. An optional switch blocks known VPN addresses from logging in or
  signing up; the list updates nightly.
- **Notifications** (in the Menu): emails every time, only when away, or a
  daily digest after some days away, optionally only on your turn; @mentions
  always email. Every email has a one-click "stop these emails" link.
  Browser pop-ups for every Passage, your turn, or after some minutes, while
  a tab is open.
- **Password reset** by email from the log-in page.

### Step 3b: Messages

- **Messages** (in the header) are out-of-character conversations between
  players, one-to-one or up to 8 others, with replies in one conversation.
- The To box takes player names or character names. While the game hides
  players, someone reached by a character's name shows only as "The player
  of" that character. "Message the player" links are on mini-profiles and
  character pages.
- The header count, emails, the digest and browser pop-ups cover Messages.

### Step 6b: Rosters

- **The roster** holds characters other players can apply to take over.
  Characters go on it when idle (if their player ticked the box), when
  their player asks and staff agree, when staff decide, or when an account
  is archived and its player ticked the box. Staff can also add new
  characters straight to it.
- **Applying** is a short note to staff. Approving one hands the character
  over with everything in character; nothing out of character comes with it.
  Each game can instead let players claim and play straight away, ask some
  application questions again (or extra ones), and/or have the new player
  redo the whole application [Decided].
- **The character directory** (Menu) lists approved characters in play and
  everyone on the roster, filtered by any public profile field.
- **Accounts are archived, not deleted.** Archived players can't log in.
  A Founder can delete an account that never had characters.

### Step 6c: Jcink add-ons

- **Beside each Passage:** the character's group and the public profile
  fields the game picked, also in the mini-profile.
- **Character groups** colour names wherever characters are listed.
- **My Chapters** lists each character's open Chapters for their player.
- **The alerts bell** collects new Passages, turns, @mentions and finished
  Chapters.
- **Chapters** can have a subtitle and staff-defined labels.

### Step 7: IC clock

- **Chapter dates:** each Chapter starts on the game's date (or one its
  starter picks) and keeps it. Its players can move it, which adds a line
  to the Chapter.
- **Front page:** the game's date, staff-written weather, and the
  characters online now.

### Step 8: Inklings

- **An Inkling** is a thread about one character, of a type the game sets.
  Players build it privately, share it with characters or groups, and send
  it to staff, which locks it until staff approve or ask for changes.
- **Entries** are numbered and can be for everyone, private (with staff),
  personal (only the writer) or staff-only notes. SOUL rolls can be added.
- **Staff** start staff types for characters and grant rewards (XP, Boons
  and Banes, Culminations, notes) that go through SOUL.

### Step 9: Grimoire

- **Branches** of magic each use a SOUL Skill. **Spells** need a rating in
  it to learn, cost XP, and are cast in Chapters as a roll of that Skill.
- Players propose spells; staff approve them. Off unless a game turns it on.

### Step 9b: Wiki

- Pages in Markdown that anyone with an account can write, with tags,
  search and full history. `[[Page name]]` links pages; a line like
  `{{characters group="Ravens"}}` shows a live list from the game.
- Staff lock pages and list them in the Menu. Scribes and Wellkeepers
  delete them. Details in `decisions.md`.

### Step 10: Platform

- Admin → Features holds every system's on/off switch.
- Admin → Look sets colours, fonts and extra CSS, served as /skin.css after
  the built-in stylesheet, with a few ready-made looks. Details in
  `decisions.md`.

### Patterns from old MUSH logs (reference)

The owner shared four logs from 2009 and 2010 MUSHes as examples. They are not kept in the repository: the descriptions in them aren't all the owner's, so none of their text may be used as default or sample content. Patterns noted from them:

- Room headers read "Room - Area - Region", sometimes with a short area code in front.
- Exits have short aliases. Some rooms list sub-rooms apart from exits, and big buildings use a directory you pick a room from.
- A saved-places list sends you to a favourite room after a short delay.
- The who and where lists show location, area and idle time. Some characters can be set unfindable.
- Arrive and leave messages show as people move.
- Players agree who opens a scene, and the pose order nudges with "It is your turn."
- OOC remarks are mixed into scenes: brb, pausing, agreeing when to resume, and "lasts" (a recap of the last poses for someone coming back).
- Scenes are paused and picked up again across days.
- There's a public channel, plus private pages and mail.

## 7. Reference: existing Inklings plugin

Inklings currently exists as an AresMUSH contrib plugin (Ruby, Ohm/Redis-backed
models) providing threaded messaging and plot tracking. It was left
mid-implementation. It lives in a separate codebase and is not part of this
repo.

- It will need to be reimplemented here, not ported, because it depends on
  Ares-specific APIs.
- Design rules that should carry over:
  - Character creation and the inkling approval workflow stay completely
    separate systems.
  - A staff reply never counts as approval. There must be no auto-unlock on
    reply.
  - Inkling types are configurable (YAML in the Ares version).
- Known unfinished parts in the Ares version (for awareness, not for this
  repo): approval-workflow rework, three missing locale keys, stale auto-unlock
  code in reply/private commands, and a missing reward command.

## 8. Open questions for the owner

1. Project name: Inkwll (tentative).
2. Setting and tone: neutral for now (decided 2026-10-14), so avoid baking in setting-specific content.

## 9. Working agreements for Claude Code

The full rules for any AI helper are in [`AGENTS.md`](../AGENTS.md).

- Make small, targeted changes. Do not expand scope or restructure without
  being asked.
- Explain changes in plain language. The owner is not an experienced
  programmer.
- Do not invent APIs or library behavior. Check real documentation or source
  before using something unfamiliar.
- Keep this document and `CHANGELOG.md` current as decisions are made.
- Ask before choosing between options on anything marked [Proposed].
