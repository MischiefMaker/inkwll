# Decisions

Every choice the owner has settled, newest first. Each entry says what was decided and, where it helps, why.

Only things the owner decided go here. Ideas that still need the owner's yes are marked **[Proposed]** in `design.md` until they are settled.

To add one: copy an entry, put it at the top, and fill in today's date.

---

## 2026-10-14: Inklings and Grimoire keep their rules

Both are rebuilt to work the way their AresMUSH versions do. The changes: Grimoire uses SOUL skills and rolls instead of FS3, and Inklings' unfinished approval-workflow rework is completed in the rebuild.

## 2026-10-14: XP follows SOUL's rules

1 XP each week, plus 1 XP to every approved participant when a Chapter finishes, with no cap. Players who fall behind get SOUL's catch-up XP (double). SOUL's forum award is dropped because Inkwll has no forum. All the numbers are game settings.

## 2026-10-14: What locks a character

When a game uses approval, everything that normally locks (such as Resonance) locks when staff approve the character. When a game turns approval off, the player clicks a "Finalize character" button instead, after a warning, and the same things lock.

## 2026-10-14: What Storytellers can do

In Chapters they run, Storytellers can call and rule GM-assisted rolls, see the Aspects and Skills of the players in that Chapter, and propose plot rewards, which staff must approve. They never see secret details: secret Boons and Banes, private Inklings, XP ledgers, Narrative History or the staff audit trail.

## 2026-10-14: Every character has a profile and application

Each character has a profile where its information is stored and read. It holds the character's SOUL sheet, Grimoire spells and Inklings, plus profile and application fields each game configures (for example a background, or answers to set questions). Sections for SOUL, Grimoire and Inklings only appear when that system is switched on.

Still open: who can read each part (see `roadmap.md`).

## 2026-10-14: What staff can do with a report

Once a Chapter is reported, staff can read that Chapter, lock it, hide a Passage (the original is kept, never deleted) and send the player a warning. Suspending or banning a player is a separate admin-panel action for Scribes and Wellkeepers.

## 2026-10-14: Finishing Chapters

Anyone in a Chapter can finish it, which locks its Passages and files it in the Archives as a Manuscript. The other players get a notice and can undo the finish within 24 hours.

Quiet Chapters: after 7 days without a Passage a Chapter goes idle (it drops down the Setting's list but stays open, and a new Passage wakes it). After 30 days it finishes on its own. Both numbers are game settings.

## 2026-10-14: Themed names players see

| Code word | Players see |
| --- | --- |
| room | **Setting** |
| scene | **Chapter** |
| all finished logs | **Archives** |
| one finished log | **Manuscript** |
| pose | **Passage** |
| exit | **Path** |

Only the words players see change. The code keeps the plain words (room, scene, pose), and the visible words live in one wording file so a game can swap them for its own.

## 2026-10-14: Players can edit their poses until the scene finishes

A player can edit their own poses any time before the scene finishes. Edited poses show an "edited" mark. Staff can still see the original, so reports show what was really posted. Once the scene finishes, poses are locked.

Default picked by Claude, not yet confirmed: deleting works the same way, and leaves a "pose removed" note in its place.

## 2026-10-14: The 3-pose rule needs four players

A scene can only use the 3-pose rule when it has at least four players. Smaller scenes pick turn-based or free-for-all.

Default picked by Claude, not yet confirmed: if a 3-pose scene drops below four players, it switches to turn-based until it has four again.

## 2026-10-14: Staff levels

Names (picked 2026-10-14 to fit the Inkwll theme): **Wellkeepers**, **Scribes**, **Pages**, and **Storytellers**. Staff job flags read as "Build Page", "App Page" and so on.

0. **Founder** is a flag on some Wellkeeper accounts. Only a Founder can make someone a Wellkeeper, from the admin panel. The first Founder is set from the server's command line when the game is installed.
1. **Wellkeeper**, the top level (like Head Wizards on a MUSH; there can be several). Can do almost anything, except make another top-level staff member. That takes a higher permission that is not a character, such as an extra password or a special flag on a top-level account.
2. **Scribe**, admin (like Wizards). Can do almost everything a Wellkeeper can, except fundamental changes to the game, such as deleting or renaming things.
3. **Page**, staff. Gets individual job flags, for example Build Page (create and delete rooms and exits) and App Page (review character applications and approve or deny them). More flags can be added later.
4. **Storyteller.** A flag on a player, not really staff. Storytellers can run approved plots and use some SOUL and Inklings tools, but cannot see other players' secret details.

This replaces part of the earlier "Lurkers and storytellers" entry: storytellers can use some SOUL tools, not none. Which tools count as "some" is decided when SOUL and Inklings are planned.

## 2026-10-14: Step 1 choices reviewed

1. **One name:** the login name and the player name are the same thing. Player names keep the current rules (letters, numbers, underscores).
2. **Deleting characters:** only the highest level of admin can delete a character. Inkwll needs several staff levels.
3. **Character names** stay unique across the whole game, and may include spaces and special characters. (Player names may not.)
4. **Starting room:** keep the builder's "New characters start here" tick, and the game ships with a default starting room so there is always one.
5. **Exits** stay one-way, but the exit form gets an easy way to create the matching return exit at the same time.
6. **Looking vs. being there:** kept as built.
7. **Remembered character rule:** kept as built.
8. **Staff:** a staff member is a player account with a staff flag, set from an admin panel on the website rather than the command line. Every admin task should be doable from that panel, gated by staff level.

## 2026-10-14: Keeping turn-based scenes moving

- Players can always pass their turn, and a storyteller can skip a player.
- **Auto-skip** is on by default and can be turned off. With it off, only passing and storyteller skips move the turn on.
- **Timer:** 5 minutes from the previous pose by default. When it runs out, the player whose turn it is gets a warning and 2 more minutes to click an "I'm here!" button. If they don't, their turn is skipped.
- **Posting out of turn:** allowed, after a warning with a "Post anyway" button.

Defaults picked by Claude, not yet confirmed: the game sets the default and each scene's creator can change it; the 5-minute timer is adjustable per scene; clicking "I'm here!" starts a fresh 5 minutes.

## 2026-10-14: Lurkers and storytellers

- **Lurkers:** anyone can watch a joinable (open, public) scene live without posing. Private and hidden scenes have no lurkers.
- **Storyteller flag:** storyteller status is its own flag on a player, separate from being staff, so staff can make trusted players storytellers. Only a flagged player (or staff) can take the storyteller role in a scene.
- ~~**SOUL storyteller tools are staff only.**~~ Changed the same day: see "Staff levels" above.

## 2026-10-14: Email on accounts is required by default, games can relax it

New accounts need an email address by default, used for password reset links. Each game can switch this to optional; players without an email then ask staff to reset their password. Sending email needs a mail-sending service, set up in the Going live step.

The owner first picked "optional", then changed it the same day.

## 2026-10-14: Character approval is a game setting

Each game chooses whether new characters need staff approval before they can pose in scenes. Unapproved characters can still move between rooms and use OOC chat. Inklings approvals stay a separate system either way.

When approval is off, a "Finalize character" button does the locking (see "What locks a character").

## 2026-10-14: Build order adopted

The owner adopted the 11-step order in `roadmap.md`: Foundation, Scenes, Logs and safety, Character approval, SOUL basics, SOUL extras, IC clock, Inklings, Grimoire, Platform, Going live.

Why: SOUL is the backbone, and Inklings rewards and Grimoire spells both depend on it.

## 2026-10-14: Hosting confirmed, plus nightly database backups

After comparing Hetzner, Render, Fly.io, Heroku and DO App Platform, the owner kept one DigitalOcean droplet with Kamal. The owner already knows DigitalOcean, and none of the others was clearly cheaper or simpler. Render is the fallback if the owner later wants no server to look after.

Backups, set up during the deployment step:

- Turn on DigitalOcean's droplet backups, which copy the whole server.
- Add a Kamal accessory in `config/deploy.yml` that copies the database every night and uploads it to a DigitalOcean Spaces bucket, so the copies live off the server.
- The owner creates the Spaces bucket and its access key. The key goes in Kamal's secrets file, never in the code.

Why: a copy of the whole server can catch PostgreSQL mid-write. A nightly database-only copy is the safer one to restore from.

## 2026-10-14: SOUL, Inklings and Grimoire are the default systems

SOUL is the backbone of the stats and character system. Inklings supports roleplay (threaded requests, plot tracking, storyteller tools). Grimoire supports magic, for games that want it. All three are rebuilt for Inkwll rather than ported from AresMUSH, and each can be switched on or off with the feature toggles, leaving room for alternative plugins later.

Reference repos: [ares-soul-plugin](https://github.com/MischiefMaker/ares-soul-plugin), [ares-inklings-plugin](https://github.com/MischiefMaker/ares-inklings-plugin), [ares-grimoire-plugin](https://github.com/MischiefMaker/ares-grimoire-plugin).

How they plug into the core is still **[Proposed]**; see `design.md`.

## 2026-10-14: Staff see a hidden scene only when it is reported

Admins cannot browse hidden scenes. A report on a hidden or private scene gives staff access to that one scene's log, and nothing more. The UI must say this when a scene is set private or hidden, and on the report form.

## 2026-10-14: Hosting on one DigitalOcean server with Kamal

The Rails app and PostgreSQL run together on a single DigitalOcean droplet, deployed with Kamal (it comes with Rails 8). No Redis or other services that need extra hosting. Building and testing stays in the cloud until launch.

Why: cheapest option that fits, and Rails 8's built-in Solid Cable, Solid Queue and Solid Cache remove the need for Redis.

## 2026-10-14: Stack is Rails 8, Hotwire and PostgreSQL

Same language as the owner's existing plugins, live updates with little custom JavaScript, and strong conventions that make AI-written code more reliable.

## Before 2026-10-14: Game rules from the planning handoff

These were settled during planning. The full detail is in `design.md`.

- **Accounts and characters:** one login per player; characters are sub-accounts switched with a dropdown. The app remembers the last character used in each room and each scene.
- **Presence:** a character is always in exactly one room, and can be in several scenes at once.
- **Scene visibility:** joinable (default), private (visible but invite-only), or hidden (only its players can see it). Hidden always means private too.
- **Logs:** finished scenes stay attached to the room and to every character in them. Visibility rules decide who can read them. A hidden log becomes public only if every player agrees.
- **Reporting:** built-in report tools.
- **Pose order, set per scene:** turn-based (default), free-for-all, or the 3-pose rule.
- **Game time:** a configurable IC clock with an offset and a ratio. Each scene can override its date, and the date only moves when the players agree.
- **OOC chat:** one site-wide OOC chat using player names.
