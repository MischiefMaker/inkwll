# Roadmap

The order Inkwll gets built in. The owner adopted this order on 2026-10-14 and can still reorder it.

The owner reviews each step before the next one starts.

Status: **Now**, **Next**, **Later** or **Done**.

| Step | What it covers | Status |
| --- | --- | --- |
| 1. Foundation | Accounts, characters with the switcher (remembering the last character per room and scene), rooms with exits and click-to-move, site-wide OOC chat. | Done |
| 1b. Step 1 changes | From the owner's review: one login/player name, an email field, character names with spaces and special characters, a default starting room, a "create the return exit too" option, staff levels and a first admin panel (setting staff, building, deleting characters for the top level), and the per-game settings for email and approval. | Now |
| 2. Scenes | Create, join and leave scenes; joinable, private and hidden; the three pose modes; live updates; unread markers. | Next (after you review step 1) |
| 3. Logs and safety | Finishing scenes, room and character log pages, reporting, the hidden-to-public consent flow. | Later |
| 4. Character approval | A character profile, submitting a character, staff approving it. Each game chooses whether approval is required. | Later |
| 5. SOUL basics | Character sheet (Aspects, Skills, Resonance), XP ledger and spending, rolls as a pose type in scenes, XP for finished scenes. | Later |
| 6. SOUL extras | Boons and Banes, Culminations, GM-assisted rolls, Narrative History and the staff audit trail. | Later |
| 7. IC clock | Game time and per-scene date overrides. | Later |
| 8. Inklings and storyteller tools | Requests, plot tracking and storyteller tools, applying approved outcomes through SOUL. | Later |
| 9. Grimoire | Magic branches tied to SOUL skills, learning spells with XP, casting as SOUL rolls, player spell proposals. | Later |
| 10. Platform | Feature toggles screen, skins. Each system gets a simple on/off switch when it is built; this step adds the screen for it. | Later |
| 11. Going live | Deploy to the DigitalOcean server with Kamal, backups, and the mail service for password reset emails. | Later |

## Decisions still needed

In the order they block building. Each one moves to `decisions.md` once the owner answers.

**Now (before step 2 starts)**

4. Staff level names, and how a new top-level staff member is made (see "Staff levels" in `decisions.md`).

**Before step 2: Scenes**

7. The 3-pose rule in small scenes (wait for fewer poses when there are only two or three players).
8. Can players edit or delete their own poses, and for how long?

**Before step 3: Logs and safety**

9. Who finishes a scene, and when does a quiet scene count as idle?
10. What staff can do with a report (read the log, lock the scene, remove a pose, warn a player).

**Before SOUL, Inklings and Grimoire**

11. Which SOUL pieces make the first version (see steps 5 and 6 above).
16. Exactly which SOUL and Inklings tools storytellers get, and which details count as secret.
17. When a game turns character approval off, when does Resonance lock (at creation, or at the first scene)?
12. How much XP a finished scene gives, and whether there is a weekly cap.
13. Whether Inklings and Grimoire keep their AresMUSH rules as they are, or change in the rebuild.

**Later**

14. Skins: CSS-only themes, or also swappable page layouts.
15. Setting and tone of the first game (the code stays setting-neutral either way).

## When a step finishes

1. Change its status to **Done** and the next one to **Now**.
2. Add a line to `CHANGELOG.md`.
3. Break the next step into task files in `tasks/` before building it.
