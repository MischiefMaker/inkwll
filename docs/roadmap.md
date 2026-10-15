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

## Version 2.0 (later, not in the current plan)

Ideas the owner wants after the first release. Not built until the owner says so.

- **Mini-map:** the Streets (Paths of type Street) make up a map; buildings and outdoor spaces sit on streets (owner, 2026-10-15). Note only, not built.
- **Private Game option:** an admin setting that turns off guests, so you must be logged in to see anything. The main URL redirects to the login page when you're not logged in. Registering could also take an optional admin approval step before a new player can take part (owner, 2026-10-15). Note only, not built.
- **More Wiki features from Wikidot:** borrow ideas from Wikidot's modules (https://www.wikidot.com/doc-modules:start), especially ListPages (lists of pages filtered by tag, category and so on) (owner, 2026-10-15). Note only, not built.
- **Wiki Infoboxes:** a boxed summary of facts at the side of a wiki page, like Wikimedia's infoboxes, or done the Wikidot way (owner, 2026-10-15). Style still to be decided. Note only, not built.
- **Chapter tabs position:** a game setting to show the Chapter tabs along the top (as now) or down the left side (owner, 2026-10-15). Note only, not built.
- **Saving drafts as people write:** what a player is typing (Passages, wiki pages, posts, messages) is saved as a draft along the way, so nothing is lost if the page closes or reloads (owner, 2026-10-15). Note only, not built.
- **Weather system:** a weather system for the game world (owner, 2026-10-15). Details to be decided. Note only, not built.
- **Mass actions on the admin lists:** checkboxes on the admin Players and staff and Characters pages, to Roster, Archive or Retire many at once (owner, 2026-10-15). Note only, not built.
- **Research: more RPG forum and hosting examples:** look at other roleplaying forums and game hosts (beyond Jcink, Wikidot and AresMUSH, which are already studied) for ideas to borrow (owner, 2026-10-15). Research task only, not started.
- **Live private chat:** players chat privately in real time, shown as tabs inside the OOC sidebar. Builds on Messages (step 3b).
- **Awards and profile comments** (from the Jcink shortlist, maybe later).
- **Deploy a new game from the web:** an admin section, for the top level of staff only, that rolls out a new game (its own install and database, as decided) without using the command line.
- **Crafting:** characters make items (owner, 2026-10-14). Details to be decided.
- **Economy:** money or trade between characters (owner, 2026-10-14). Details to be decided.
- **Mini map:** a small map of the Settings around you, beyond the compass's next step. Needs each Setting placed on a grid first (owner, 2026-10-14).
- **IC or OOC Boards:** an admin setting on each Board for whether people post in character or out of character (owner, 2026-10-15). OOC posts show the player name, as now. IC posts let the poster choose which of their characters to post as, for IC boards or posting things as your character. Details to be decided.
- **Templates beyond CSS:** let games change the page layouts themselves, not just colours and fonts. Study how Jcink's template system works for inspiration first: https://jcink.com/wiki/jfh-html-templates

## Decisions still needed

In the order they block building. Each one moves to `decisions.md` once the owner answers.

All open design questions were answered on 2026-10-14. New ones get added here as they come up.

**To revisit later**

- A themed word for Areas (kept as "Area" for now).

## When a step finishes

1. Change its status to **Done** and the next one to **Now**.
2. Add a line to `CHANGELOG.md`.
3. Break the next step into task files in `tasks/` before building it.
