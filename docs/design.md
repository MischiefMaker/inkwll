# Inkwll design

This document records what has been decided, what is only proposed, and what is
still open. It started as the planning handoff and is kept up to date as
decisions are made.

**Status key:** **[Decided]** came from the project owner. **[Proposed]** is a
suggestion that still needs the owner's confirmation; don't treat it as settled.

## 1. Concept

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

### Stack and hosting [Decided]

- Ruby on Rails 8 + Hotwire (Turbo + Stimulus) + PostgreSQL.
- Built and tested in the cloud (Claude Code on the web, GitHub Actions CI).
- Will eventually be hosted on a server such as DigitalOcean.

### Accounts and characters [Decided]

- One player account (username/password). Characters are sub-accounts with no
  separate login.
- A dropdown switches the active character.
- The app remembers which character the player last used in each room and each
  scene, and applies it automatically.

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

### Logs [Decided]

- Finished chats remain attached to the room and linked to each participating
  character, so logs can be viewed from both places.
- The public/private/hidden rules above determine who can read them.

### Moderation and reporting [Decided]

- Built-in reporting tools.
- If a private or hidden scene is reported, staff can see its log.
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

### OOC chat [Decided]

- One persistent OOC chat, using player names (not character names), visible
  site-wide like a forum Cbox.

### Inklings / Grimoire / SOUL [Decided in intent, details unknown]

- The owner's Inklings, Grimoire, and SOUL systems are meant to sit at the core
  of the game.
- Special storyteller/GM tools will be delivered through Inklings.
- Grimoire and SOUL have not been described yet. See open questions.

## 4. Proposals (confirm before relying on them)

### Extensibility [Proposed]

- Start with a `features` settings table. Each module checks whether it is
  enabled.
- Skins via CSS variables plus swappable view folders. (The stylesheet already
  keeps colours and fonts in CSS variables; nothing else is built yet.)
- Package modules as Rails engines later, once real plugin needs are known. Do
  not build a plugin system first.

### Data model (draft) [Proposed]

Items built in step 1 are marked ✅.

- ✅ Account: login, display name (OOC identity), active character.
- ✅ Character: belongs to an account.
- ✅ Room, Exit: description, links. *Optional parent area: not built yet.*
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
  enforces turn order. The browser never decides whose turn it is.
- Turn-based mode needs escape hatches: a "pass" button, a storyteller
  override, and a way to skip an absent player.
- 3-pose rule in small scenes: use `min(3, participants - 1)` other poses,
  since two players could otherwise never pose.
- IC time: `ic_now = epoch + (real_now - anchor) * ratio`. A scene override
  stores its own date and changes only through a "propose time skip" that the
  other players accept.
- Staff cannot browse hidden scenes. A report grants access to that one scene.

## 5. Roadmap [Proposed]

1. ✅ **Foundation**: accounts, characters with switcher, rooms and exits,
   site-wide OOC chat.
2. **Scenes**: create, join, leave, the three visibility states, three pose
   modes, live updates, unread markers.
3. **Logs and safety**: finishing scenes, room and character log pages,
   reporting, hidden-to-public consent flow.
4. **IC clock**: game time and per-scene overrides.
5. **Inklings** and storyteller tools.
6. **Platform**: feature toggles UI, skins, plugin packaging.

## 6. How step 1 works (choices to confirm)

These are the small choices made while building step 1. Each is easy to
change; the owner should confirm or adjust them.

- **Login name vs. player name.** Accounts log in with a *username*
  (letters, numbers, underscores; capitals are ignored when logging in). A
  separate *player name* is what other people see in the OOC chat.
- **No password reset yet.** Rails' built-in reset works by email, and accounts
  don't have an email address. Until that's decided, staff would reset a
  password from the Rails console.
- **Characters can't be deleted yet**, because deleting them will matter once
  logs exist.
- **Character names are unique** across the whole game (ignoring capitals).
- **New characters appear in the starting room.** A builder ticks "New
  characters start here" on one room. If none is ticked, the oldest room is
  used.
- **Exits are one-way.** A two-way passage is two exits, one in each room.
- **Looking vs. being there.** Anyone can open any room page from the Rooms
  list to look at it. Exit buttons only work when the active character is in
  that room.
- **Remembered character rule.** When you open a room page: if the character
  you last used there is still in that room, it becomes active automatically;
  otherwise, if your active character is in that room, it is remembered for
  next time. Switching with the dropdown or walking through an exit also
  updates the memory.
- **Live updates.** The room page updates its "Here" list live when someone
  enters or leaves. OOC messages appear live for everyone, and the OOC panel
  stays put while you move between pages.
- **Staff.** Accounts have an `admin` flag. Admins see a *Build* link for
  creating and editing rooms and exits. To make someone an admin, run
  `bin/rails "inkwll:make_admin[username]"`.

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
2. What are Grimoire and SOUL, and how should they integrate with the core?
3. Can admin see hidden scenes? Current lean: no, except via a report.
4. Hosting details: DigitalOcean is the likely target. Which kind (a plain
   server/droplet or their App Platform) affects how the database and live
   updates are set up.
5. Setting and tone: not specified, so avoid baking in setting-specific content.
6. Should accounts have an email address (for password resets and notices)?

## 9. Working agreements for Claude Code

- Make small, targeted changes. Do not expand scope or restructure without
  being asked.
- Explain changes in plain language. The owner is not an experienced
  programmer.
- Do not invent APIs or library behavior. Check real documentation or source
  before using something unfamiliar.
- Keep this document and `CHANGELOG.md` current as decisions are made.
- Ask before choosing between options on anything marked [Proposed].
