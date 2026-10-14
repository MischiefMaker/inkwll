# Roadmap

The order Inkwll gets built in. The owner adopted this order on 2026-10-14 and can still reorder it.

The owner reviews each step before the next one starts.

Status: **Now**, **Next**, **Later** or **Done**.

| Step | What it covers | Status |
| --- | --- | --- |
| 1. Foundation | Accounts, characters with the switcher (remembering the last character per room and scene), rooms with exits and click-to-move, site-wide OOC chat. | Done |
| 1b. Step 1 changes | A forum-like layout with the roleplay front and centre and extras in the menu, and nestable Areas that group Settings (the homepage lists the top-level Areas). Areas and Settings can have an image, text or both. Player-facing words switch to Setting, Path, Chapter, Passage, Archives and Manuscript (one wording file). From the owner's review: one login/player name, an email field, character names with spaces and special characters, a default starting room, a "create the return exit too" option, staff levels (Founder flag, Wellkeepers, Scribes, Pages, Storytellers) and a first admin panel (setting staff, building, deleting characters for the top level), and the per-game settings for email and approval. | Now |
| 2. Scenes | Create, join and leave scenes; joinable, private and hidden; the three pose modes; live updates; unread markers; a tabbed view when a character is in several Chapters, each tab showing its Setting; a Where list; latest activity on front-page boards (never private or hidden Chapters); each Passage shows the character's name and icon, with a mini-profile pop-up or profile link. | Next (after you review step 1) |
| 3. Logs and safety | Finishing scenes, room and character log pages, reporting, the hidden-to-public consent flow, banning accounts and IP addresses, and an optional block on known VPNs. Opt-in email notifications for new activity (every time, only when logged out, or after some days away) that include the missed Passages, plus the mail-sending service they need. | Later |
| 4. Character profiles and approval | A profile for every character with game-configured profile and application fields (background, set questions, images, an optional description), each marked public or private by the game. Each game decides whether a written description and/or image is required. Every character has one icon shown beside their Passages; extra images and GIFs go on the profile. Room for SOUL, Grimoire and Inklings sections. Submitting a character, staff approving it. Each game chooses whether approval is required. | Later |
| 5. SOUL basics | Character sheet (Aspects, Skills, Resonance), XP ledger and spending, rolls as a pose type in scenes, XP for finished scenes. | Later |
| 6. SOUL extras | Boons and Banes, Culminations, GM-assisted rolls, Narrative History and the staff audit trail. | Later |
| 7. IC clock | Game time and per-scene date overrides. | Later |
| 8. Inklings and storyteller tools | Requests, plot tracking and storyteller tools, applying approved outcomes through SOUL. | Later |
| 9. Grimoire | Magic branches tied to SOUL skills, learning spells with XP, casting as SOUL rolls, player spell proposals. | Later |
| 9b. Wiki | Wikidot-style wiki in Markdown, with built-in ways to pull in characters, Manuscripts, Settings and so on (for example by tag). Rules, lore and plots live here, reached from the menu. Any player can edit, with full history; staff can lock pages. | Later |
| 10. Platform | Feature toggles screen, CSS skins (colors, fonts, extra CSS) from the admin panel. Each system gets a simple on/off switch when it is built; this step adds the screen for it. | Later |
| 11. Going live | Deploy to the DigitalOcean server with Kamal, backups, and password reset emails (the mail service is set up in step 3). | Later |

## Decisions still needed

In the order they block building. Each one moves to `decisions.md` once the owner answers.

All open design questions were answered on 2026-10-14. New ones get added here as they come up.

**To revisit later**

- A themed word for Areas (kept as "Area" for now).

## When a step finishes

1. Change its status to **Done** and the next one to **Now**.
2. Add a line to `CHANGELOG.md`.
3. Break the next step into task files in `tasks/` before building it.
