# Roadmap

The order Inkwll gets built in. This order came from planning and is still **[Proposed]**: the owner can reorder it.

The owner reviews each step before the next one starts.

Status: **Now**, **Next**, **Later** or **Done**.

| Step | What it covers | Status |
| --- | --- | --- |
| 1. Foundation | Accounts, characters with the switcher (remembering the last character per room and scene), rooms with exits and click-to-move, site-wide OOC chat. | Done |
| 2. Scenes | Create, join and leave scenes; joinable, private and hidden; the three pose modes; live updates; unread markers. | Next (after you review step 1) |
| 3. Logs and safety | Finishing scenes, room and character log pages, reporting, the hidden-to-public consent flow. | Later |
| 4. IC clock | Game time and per-scene date overrides. | Later |
| 5. Inklings and storyteller tools | Requests, plot tracking and storyteller tools, applying approved outcomes through SOUL. | Later |
| 6. Platform | Feature toggles screen, skins, plugin packaging. | Later |

Step 1 left a few small choices for the owner to confirm; they are listed in `design.md` section 6.

### Proposed new order [Proposed]

Claude's suggestion for where SOUL, Grimoire, character approval and going live fit. Not settled until the owner says yes; the table above stays in charge until then.

1. **Foundation** (done)
2. **Scenes**
3. **Logs and safety**
4. **Character approval**: a character profile, submitting a character, staff approving it. SOUL needs this, because Resonance locks at approval.
5. **SOUL basics**: character sheet (Aspects, Skills, Resonance), XP ledger and spending, rolls as a pose type in scenes, XP for finished scenes.
6. **SOUL extras**: Boons and Banes, Culminations, GM-assisted rolls, Narrative History and the staff audit trail.
7. **IC clock**
8. **Inklings and storyteller tools**
9. **Grimoire**
10. **Platform**: feature toggles screen, skins. Each system gets a simple on/off switch when it is built; this step adds the screen for it.
11. **Going live**: deploy to the DigitalOcean server with Kamal, backups, and email if accounts get one.

## Decisions still needed

In the order they block building. Each one moves to `decisions.md` once the owner answers.

**Now (before step 2 starts)**

1. The roadmap order above, including where SOUL and Grimoire go.
2. Do characters need staff approval before they can play?
3. Should accounts have an email address, and is it required?
4. The step 1 choices listed in `design.md` section 6.

**Before step 2: Scenes**

5. Who can be a scene's storyteller, and can people watch without posing (lurkers)?
6. Turn-based mode's escape hatches: a pass button, a storyteller override, and skipping someone who has gone quiet.
7. The 3-pose rule in small scenes (wait for fewer poses when there are only two or three players).
8. Can players edit or delete their own poses, and for how long?

**Before step 3: Logs and safety**

9. Who finishes a scene, and when does a quiet scene count as idle?
10. What staff can do with a report (read the log, lock the scene, remove a pose, warn a player).

**Before SOUL, Inklings and Grimoire**

11. Which SOUL pieces make the first version (see steps 5 and 6 above).
12. How much XP a finished scene gives, and whether there is a weekly cap.
13. Whether Inklings and Grimoire keep their AresMUSH rules as they are, or change in the rebuild.

**Later**

14. Skins: CSS-only themes, or also swappable page layouts.
15. Setting and tone of the first game (the code stays setting-neutral either way).

## When a step finishes

1. Change its status to **Done** and the next one to **Now**.
2. Add a line to `CHANGELOG.md`.
3. Break the next step into task files in `tasks/` before building it.
