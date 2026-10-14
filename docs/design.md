# Inkwll design

This document records what has been decided, what is only proposed, and what is
still open. It started as the planning handoff and is kept up to date as
decisions are made.

**Status key:** **[Decided]** came from the project owner. **[Proposed]** is a
suggestion that still needs the owner's confirmation; don't treat it as settled.

## 1. Concept

Players see themed words: a room is a **Setting**, an exit is a **Path**, a
scene is a **Chapter**, a pose is a **Passage**, and finished logs are
**Manuscripts** in the **Archives**. This document and the code use the plain
words.

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

- One player account (username/password). Characters are sub-accounts with no
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
- Character approval is a per-game setting. When it is on, new characters
  cannot pose in scenes until staff approve them.

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
  scene's storyteller role.
- Finishing a scene awards SOUL XP to its approved participants.
- Grimoire spells use SOUL skills, and casting a spell is a SOUL roll.
- The rest of the app talks to "the character system" through a small
  interface, so SOUL could be swapped out. Grimoire and Inklings must work
  correctly when they are disabled.
- Following the extensibility proposal, start with the `features` table, and
  do not build a plugin system first.

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
  tracks whose turn it is. The browser never decides whose turn it is.
- [Decided] Turn-based mode: players can pass, storytellers can skip, and
  auto-skip (on by default, can be turned off) warns a player 5 minutes after
  the previous pose and skips them 2 minutes later unless they click
  "I'm here!". Posting out of turn shows a warning with a "Post anyway"
  button.
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

## 6. How step 1 works

These are the small choices made while building step 1. The owner reviewed
them on 2026-10-14 (see `decisions.md`); the changes are roadmap step 1b and
are not built yet:

- [Decided] Login name and player name are the same.
- [Decided] Only the highest staff level can delete characters.
- [Decided] Character names may use spaces and special characters.
- [Decided] The game ships with a default starting room.
- [Decided] The exit form can create the return exit at the same time.
- [Decided] Staff levels, set from an admin panel on the website, which
  handles every admin task. The levels themselves are still open.

How it works today:

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
2. Setting and tone: not specified, so avoid baking in setting-specific content.

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
