# Roadmap

The order Inkwll gets built in. The owner adopted this order on 2026-10-14 and can still reorder it.

The owner reviews each step before the next one starts.

Status: **Now**, **Next**, **Later** or **Done**.

| Step | What it covers | Status |
| --- | --- | --- |
| 1. Foundation | Accounts, characters with the switcher (remembering the last character per room and scene), rooms with exits and click-to-move, site-wide OOC chat. | Done |
| 1b. Step 1 changes | A forum-like layout with the roleplay front and centre and extras in the menu, and nestable Areas that group Settings (the homepage lists the top-level Areas). Areas and Settings can have an image, text or both. Player-facing words switch to Setting, Path, Chapter, Passage, Archives and Manuscript (one wording file). From the owner's review: one login/player name, an email field, character names with spaces and special characters, a default starting room, a "create the return exit too" option, staff levels (Founder flag, Wellkeepers, Scribes, Pages, Storytellers) and a first admin panel (setting staff, building, deleting characters for the top level), and the per-game settings for email and approval. | Done |
| 2. Scenes | Create, join and leave scenes; joinable, private and hidden; the three pose modes; live updates; unread markers; a tabbed view when a character is in several Chapters, each tab showing its Setting; a Where list; arrival and departure lines; new Chapters start where the character stands; latest activity on front-page boards (never private or hidden Chapters); a count in the browser tab and a dot on the favicon when there's something new; each Passage shows the character's name and icon, with a mini-profile pop-up or profile link. | Built, waiting for you to try it |
| 3. Logs and safety | Finishing scenes, room and character log pages, reporting, the hidden-to-public consent flow, banning accounts and IP addresses, and an optional block on known VPNs. Opt-in email notifications for new activity (every time, only when logged out, or after some days away, optionally only on your turn) that include the missed Passages, and optional browser notifications, plus the mail-sending service they need. Password reset emails. | Built, waiting for you to try it |
| 3b. Messages | Out-of-character private Messages between players, one-to-one or in small groups, including "to the player of" a character, which keeps the player hidden when the game hides players, with an unread count and the same email and browser alerts as Chapters. | Built, waiting for you to try it |
| 4. Character profiles and approval | A profile for every character with game-configured profile and application fields (background, set questions, images, an optional description), each marked public or private by the game. Each game decides whether a written description and/or image is required. Every character has one icon shown beside their Passages; extra images and GIFs go on the profile. Player profiles (icon, name, About me, and their characters when the game shows players). Character profiles with Demographics (age worked out from the birthday by the in-character clock, so a basic game date comes with this step), an Application tab, SOUL, Inklings and Grimoire sections, a gallery, relationships and their public logs. Submitting a character, staff approving it. Each game chooses whether approval is required. | Built, waiting for you to try it |
| 5. SOUL basics | Character sheet (Aspects, Skills, Resonance), XP ledger and spending, rolls as a pose type in scenes, XP for finished scenes. | Built, waiting for you to try it |
| 6. SOUL extras | Boons and Banes, Culminations, GM-assisted rolls, Narrative History and the staff audit trail. | Built, waiting for you to try it |
| 6b. Rosters | A list of characters other players can apply to take over, with staff approval; idle characters go back on it. A public character directory that includes the roster and filters by public profile fields. Archiving accounts instead of deleting them. | Built, waiting for you to try it |
| 6c. Jcink add-ons | Mini-profile fields beside Passages, a “My Chapters” tracker, an alerts bell, Chapter subtitles and staff labels, and character groups that colour names. | Built, waiting for you to try it |
| Security | The owner's security rules from the review: upload limits, HTTPS, email changes, hidden Chapters, staff locks, Scribe bans, posting limits with a cool-off, password rules. See "Security rules" in `decisions.md`. | Built, waiting for you to try it (HTTPS switches on at the first deploy) |
| 7. IC clock | The rest of game time (the basic game date comes in step 4) and per-scene date overrides. | Built, waiting for you to try it |
| 8. Inklings and storyteller tools | Requests, plot tracking and storyteller tools, applying approved outcomes through SOUL. | Built, waiting for you to try it |
| 9. Grimoire | Magic branches tied to SOUL skills, learning spells with XP, casting as SOUL rolls, player spell proposals. | Built, waiting for you to try it |
| 9b. Wiki | Wikidot-style wiki in Markdown, with built-in ways to pull in characters, Manuscripts, Settings and so on (for example by tag). Rules, lore and plots live here, reached from the menu. Any player can edit, with full history; staff can lock pages. | Built, waiting for you to try it |
| 10. Platform | Feature toggles screen, CSS skins (colors, fonts, extra CSS) from the admin panel. Each system gets a simple on/off switch when it is built; this step adds the screen for it. | Built, waiting for you to try it |
| 11. Going live | Deploy to the DigitalOcean server with Kamal, backups, and choosing the mail service (the emails themselves are built in step 3). | Later |
| 12. Wells | A Founder-only Wells page for running several games (Wells). 12a: the page plus Update and Go back for this Well, using versions Claude marks ready, with a backup before each update. 12b: a new Well on the same droplet at a subdomain (DNS moves to DigitalOcean first). 12c: a new Well on a new droplet. 12d: a Well's own domain. See `docs/wells.md`. | 12a done (v1.0); 12b built, waiting for the DNS move and v1.1; 12c and 12d Next |

## Version 2.0 (later, not in the current plan)

Ideas the owner wants after the first release. Not built until the owner says so.

### The order (adopted by the owner, 2026-10-17)

Claude grouped every note below into themes and suggested this order, and the owner adopted it on 2026-10-17. The owner can still reorder, merge or drop anything, and nothing is built until the owner says so. Each theme lists its items by the names used in the notes further down.

The order goes from small, everyday improvements to big new systems. The early themes reuse things Inkwll already has, so they are quicker and safer. The later ones need new design talks first.

**Theme 1: Quick wins.** Small changes that make every day smoother. Each one stands alone, so any can be done first.
- Saving drafts as people write. Nothing is lost if the page closes.
- Mass actions on the admin lists. Tick several characters, then Roster, Archive or Retire them at once.
- Chapter tabs position (top or left side).
- Private Game option, with the optional approval step for new players.
- Away notice.
- New player badge.
- Birthdays this month. Uses the birthdays and IC clock that already exist.
- Graveyard. A Deceased status beside Retired, and its own page.

**Theme 2: Finding someone to RP with.** This theme serves the "fewer cliques" aim most directly, so it comes early.
- Looking for RP flag. Comes first, because the next item needs it.
- Looking for a scene nudge. Needs the Looking for RP flag.
- Storyteller wanted, and the Need a ruling button next to it. Both are ticks on a Chapter that put it on a list.
- Scene prompt ("Give me an idea").
- Random character spotlight on the front page.
- Random scene bounty. Uses SOUL XP, which already exists.
- Census of active characters per group. Uses the groups that already exist.

**Theme 3: Inside a Chapter.** New things to do while writing.
- The story so far, plus the one-line version in the Bookshelf list. Do these together, since the one-line version is the same summary.
- Chapter speed toggle (live chat or forum speed). Builds on the Chat, Manuscript and Forum layouts that are already built.
- Mutter (a whisper Passage).
- In-character letters and texts (a Passage type).
- Live private chat and pages, plus private Storyteller asides. Builds on Messages.

**Theme 4: NPCs, groups and factions.** Who characters are and who they belong to.
- NPCs (one feature, owner 2026-10-17): staff make NPCs in the admin panel, and anyone running a Chapter can pick one.
- Group pages, ranks and an IC board.
- IC or OOC Boards. Do this with the group pages, since a group's IC board needs it.
- Factions or teams, public or secret, tied into Inklings. Comes after group pages, so the two can share their look.

**Theme 5: The world's history and events.**
- World timeline. Staff mark finished Chapters as world events.
- Event calendar with sign-ups. A Chapter opens when the event starts.

**Theme 6: The wiki.**
- More Wiki features from Wikidot, starting with ListPages.
- Wiki Infoboxes. The style still needs choosing.

**Theme 7: Running games (Wells) and the look.**
- Destroy a Well, with a restorable JSON backup. Steps 12c and 12d of the current plan come first.
- Templates beyond CSS. Study Jcink's templates first. This is big, because games could then change page layouts, not only colours and fonts.

**Theme 8: The physical world.**
- Mini-map. One feature: the map shows only the Streets, and the buildings appear once you're on that street. It uses the Streets that already exist, so it needs no new grid.
- Weather system. Details still to be decided.

**Theme 9: Big new systems (each needs a design talk first).** Both are optional systems that a game switches on or off, like Grimoire.
- Crafting.
- Economy. Probably goes with crafting, so the two should be designed together.

**Maybe later**
- Awards and profile comments.

### The notes

- **Create an NPC (admin):** a lighter kind of character that staff make in the admin panel. An NPC can take an icon, SOUL skills and so on, but never shows in any player's Characters list. Any GM/Storyteller can use a pre-made NPC for an NPC Passage, with a dropdown of them beside the box where you type a name (owner, 2026-10-16). This is also the shared NPC list (idea 25); the two are one feature (owner, 2026-10-17). Note only, not built.
- **Factions or teams (in addition to groups):** a character can belong to several, and each membership can be public or secret. For example, publicly in their family faction and secretly in an assassin's guild. They tie into Inklings, so an Inkling can be shared with a faction (owner, 2026-10-16). Note only, not built.
- **Chapter speed toggle:** a switch on a Chapter between live chat (instant, like the Chat look we have now) and forum speed (asynchronous, with a forum-style posting area). The toggle changes how the page looks and feels to match (owner, 2026-10-17). Note only, not built.
- **Destroy a Well:** a Founder button on the Wells page to destroy a Well, only after it has been turned off first. It takes a backup first that can be used to restore it later, in the same JSON format the world export/import already uses (owner, 2026-10-17). Note only, not built.
- **Mini-map:** the Streets (Paths of type Street) make up a map; buildings and outdoor spaces sit on streets (owner, 2026-10-15). The map shows only the streets, and when you're on a street you see its buildings (owner, 2026-10-17). Note only, not built.
- **Private Game option:** an admin setting that turns off guests, so you must be logged in to see anything. The main URL redirects to the login page when you're not logged in. Registering could also take an optional admin approval step before a new player can take part (owner, 2026-10-15). Note only, not built.
- **More Wiki features from Wikidot:** borrow ideas from Wikidot's modules (https://www.wikidot.com/doc-modules:start), especially ListPages (lists of pages filtered by tag, category and so on) (owner, 2026-10-15). Note only, not built.
- **Wiki Infoboxes:** a boxed summary of facts at the side of a wiki page, like Wikimedia's infoboxes, or done the Wikidot way (owner, 2026-10-15). Style still to be decided. Note only, not built.
- **Chapter tabs position:** a game setting to show the Chapter tabs along the top (as now) or down the left side (owner, 2026-10-15). Note only, not built.
- **Saving drafts as people write:** what a player is typing (Passages, wiki pages, posts, messages) is saved as a draft along the way, so nothing is lost if the page closes or reloads (owner, 2026-10-15). Note only, not built.
- **Weather system:** a weather system for the game world (owner, 2026-10-15). Details to be decided. Note only, not built.
- **Mass actions on the admin lists:** checkboxes on the admin Players and staff and Characters pages, to Roster, Archive or Retire many at once (owner, 2026-10-15). Note only, not built.
- **Live private chat and pages:** players chat privately in real time, shown as tabs inside the OOC sidebar, and MUSH-style pages (instant direct messages between players) fit in here too. Builds on Messages (step 3b). Also private Storyteller asides inside a Chapter (owner, 2026-10-15, idea 7 of the RP platforms shortlist). Note only, not built.
- **Awards and profile comments** (from the Jcink shortlist, maybe later).
- **Crafting:** characters make items (owner, 2026-10-14). An optional system each game can switch on, like Grimoire (owner, 2026-10-17). Details to be decided.
- **Economy:** money or trade between characters (owner, 2026-10-14). An optional system each game can switch on, like Grimoire (owner, 2026-10-17). Planned first, before Crafting, and built from scratch with Arx as a starting point (owner, 2026-10-17). Proposed design and open questions in `economy.md`.
- **IC or OOC Boards:** an admin setting on each Board for whether people post in character or out of character (owner, 2026-10-15). OOC posts show the player name, as now. IC posts let the poster choose which of their characters to post as, for IC boards or posting things as your character. Details to be decided.
- **Templates beyond CSS:** let games change the page layouts themselves, not just colours and fonts. Study how Jcink's template system works for inspiration first: https://jcink.com/wiki/jfh-html-templates

From the RP platforms shortlist (`design/rp-platforms-shortlist.md` in the project files), picked by the owner on 2026-10-15. Notes only, not built:

- **Looking for RP flag:** a per-character flag with short "I am" and "Looking for" tags, a mark in Here and Where, and a Looking for RP list (idea 1).
- **The story so far:** an editable summary pinned to the top of a Chapter, also shown in the Place's Chapter list and in the Archives (idea 3).
- **Storyteller wanted:** a tick on a Chapter that puts it on a list for Storytellers, so one can join (idea 4).
- **World timeline:** staff mark a finished Chapter as a world event, and it goes on a Timeline page with its date, a summary and the characters who were there (idea 5).
- **Event calendar with sign-ups:** an event at a Place and time; characters sign up, and a Chapter opens when it starts (idea 6).
- **Group pages, ranks and an IC board:** readable by everyone, to avoid cliques (idea 10).

Second batch from the same shortlist, picked by the owner on 2026-10-15. Notes only, not built:

- **Random scene bounty:** each week a few random active characters are picked, and a Chapter with one of them earns bonus SOUL XP (idea 13).
- **In-character letters and texts:** a new type of Passage, written messages from one character to others that show up inside Chapters. Combined with the AresMUSH Txt plugin's idea (idea 19).
- **Need a ruling button:** a button on a Chapter that asks staff to rule on something, next to Storyteller wanted.
- **Random character spotlight:** one character featured on the front page (idea 22).
- **One-line "story so far" in the Archives list:** each Manuscript shows its summary line in the list (idea 23).
- **Graveyard:** a Deceased status beside Retired, with its own page (idea 24).
- **Looking for a scene nudge:** one quiet alert to players marked Looking for RP, rate-limited (idea 29).
- **Scene prompt:** a "Give me an idea" button on the new Chapter form (idea 30).
- **Census:** active characters per group, plus a staff note on which groups need players (idea 31).
- **Birthdays this month:** a list of characters with birthdays this month (idea 38).
- **Mutter:** a whisper Passage where everyone else sees only a partial line (idea 39).

Third batch from the same shortlist, picked by the owner on 2026-10-15. Notes only, not built:

- **Away notice:** "Away until (date)" shows on a player's Chapters next to whose turn it is, and clears itself on that date (idea 40, from Alveus).
- **New player badge:** a "new" mark for a player's first two weeks, in the OOC Chat, Here and the directory (idea 44).

## Decisions still needed

In the order they block building. Each one moves to `decisions.md` once the owner answers.

All open design questions were answered on 2026-10-14. New ones get added here as they come up.

**To revisit later**

- A themed word for Areas (kept as "Area" for now).

## When a step finishes

1. Change its status to **Done** and the next one to **Now**.
2. Add a line to `CHANGELOG.md`.
3. Break the next step into task files in `tasks/` before building it.
