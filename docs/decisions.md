# Decisions

Every choice the owner has settled, newest first. Each entry says what was decided and, where it helps, why.

Only things the owner decided go here. Ideas that still need the owner's yes are marked **[Proposed]** in `design.md` until they are settled.

To add one: copy an entry, put it at the top, and fill in today's date.

## Guiding principle (owner, 2026-10-14)

Keep forum RP's easy navigation and many Chapters at once, but make the grid feel real and physical, like moving through space on a traditional MU. AresMUSH has lost much of that feeling and some games no longer build grids; Inkwll should not. When a design choice trades one against the other, protect the feeling of physical space.

## Design aim: keep cliques to a minimum (owner, 2026-10-14)

Old-school MUSHes kept cliques down partly because nobody knew who played which character. Inkwll should keep that spirit where it can, while still making it easy to reach a character's player out of character.

Players who want a separate identity for an alt can make a second player account.

## 2026-10-14: CSS classes on everything

Every element gets a CSS class so games can style things easily (owner). Classes follow `block`, `block__part` and `block--kind`, use plain words rather than themed ones, and are listed for skinners in `docs/css-classes.md`. Each page's `<body>` also gets page classes (such as `page-scenes-show`) and `is-logged-in`, `is-guest` or `is-staff`.

## 2026-10-14: Any player can post as an NPC

Any player in a Chapter can post as an NPC, labelled with who played it (owner, from a decision card). Built that way.

## 2026-10-14: Pausing a Chapter

Players can pause a Chapter to pick it up another day, with an optional "back on" note. The turn timer stops, and the game won't finish it for being quiet while it's paused (owner).

Defaults picked by Claude: any player in the Chapter can pause it or pick it back up, and posting a Passage, NPC Passage or narration picks it back up automatically (an OOC line doesn't). Paused Chapters show "Paused" on their tab and in the Setting's list.

## 2026-10-14: OOC remarks inside Chapters

OOC remarks go in the Chapter itself as OOC lines, not in a separate side chat (owner, from a decision card). Built as described under "More kinds of post in a Chapter".

## 2026-10-14: Arial as the default font

Arial is the default font everywhere, emails included, instead of Times New Roman (owner). Games can change it with CSS skins (step 10).

## 2026-10-14: Guests in the OOC Chat

People who aren't logged in can talk in the OOC Chat to ask questions, but they need a player account before they can make a character and submit an application. Spammers have to be kept out (owner).

Defaults picked by Claude, built the same day:

- Guests pick a name (not a player's name) that lasts for their visit, shown as "Name (guest)" with a grey icon.
- Guests can't post links. They can't post until a few seconds after opening the chat, a hidden box catches bots that fill in every field, and they can send at most 5 messages a minute.
- Bans and the VPN block apply to guests. The Bans page lists this week's guests by address, with buttons to ban them or remove their messages.
- A game setting turns guest chat off. It's on by default.
- The log-in page links to the chat: "Have a question first? Ask in the OOC Chat as a guest."

## 2026-10-14: More kinds of post in a Chapter

Chapters need OOC lines inside them, plus other kinds of post such as Storyteller or scene-setting narration and NPCs (owner).

Defaults picked by Claude, built the same day:

- **OOC line:** anyone in the Chapter can post one. It's small and grey with an "OOC" tag, doesn't take a turn, doesn't count as unread or go in emails, and is left out of the Manuscript (a "Show OOC lines" link brings it back).
- **Narration:** scene-setting text in a box with a coloured edge, in italics, with no icon. The Storyteller posts it, or anyone in a Chapter that has no Storyteller. It doesn't take a turn.
- **NPC:** any player in the Chapter can post as an NPC by typing its name. It shows the NPC's name and initial, marked "NPC, played by" the character. It takes the poster's turn.
- After an OOC line or narration, the box switches back to an ordinary Passage. After an NPC Passage it stays on NPC, with the name kept.
- Dice rolls come with SOUL (step 5).

## 2026-10-14: Profile layout

Fields are set by each game; these are the defaults (owner).

- **Player profiles:** the player's icon, player name, an "About me" box, and, when the game shows who plays which character, a list of their characters linking to each profile.
- **Character profiles** are where everything about a character lives, and should still look good:
  - **Demographics:** Name, Age, Birthday, Hometown, Occupation and so on. Age is worked out from the Birthday using the game's in-character clock.
  - **Application:** a separate tab, holding whatever the game makes its application.
  - **SOUL, Inklings and Grimoire** sections.
  - **Gallery.**
  - **Relationships.**
  - **Logs:** the character's public Manuscripts.

Default picked by Claude: since Age needs the in-character clock, a basic game date (offset and speed) is built with step 4, and the rest of the clock stays in step 7.

## 2026-10-14: OOC Chat look

Called "OOC Chat" everywhere. The header is a coloured bar that stays put while messages scroll, and each message has a very small icon for visual interest (owner).

Default picked by Claude: the icon is the player's initial on a colour picked from their player name, never a character's icon, which could show who plays that character. It can become the player's own uploaded icon once player profiles exist (step 4).

## 2026-10-14: Area names on Chapters and Where

A Chapter shows its Area names in smaller text above the Setting's name, and the Where list shows each Setting's Areas the same way, without links (owner).

## 2026-10-14: Step 3 details picked while building

Defaults picked by Claude while building Logs and safety, for the owner to check. Any of them can change.

- **Finishing.** Any player in a Chapter can finish it. The others can undo that for 24 hours. A Chapter with no new Passage for 7 days counts as idle, and after 30 days the game finishes it itself (both numbers are game settings). Finished Chapters stay in the tabs for 24 hours.
- **Archives.** Finished Open and Private Chapters are in the Archives, which can be filtered by Setting or character. A finished Hidden Chapter joins them only once every player in it has agreed.
- **Reports.** Scribes and Wellkeepers handle reports; Pages don't. Once a Chapter has been reported, those staff can still read it after the report is resolved, so they can look back at it. Staff can hide a single Passage (the text is kept for staff) or lock a Chapter.
- **Warnings and bans.** Staff can send a player a warning, which shows as a banner until it's read. Bans can cover an account, an IP address or a range, can end on a date or last until lifted, and log the player out at once.
- **VPN block.** Off by default. The list of VPN addresses comes from the free X4BNet list and updates every night.
- **Emails.** "Not on the site" means not seen for 10 minutes. Several new Passages in one Chapter make one email, and the next waits until the player has read it. Emails show the latest 20 missed Passages, then "and N more". @mentions of a character always email its player if they have emails on. The away-for-days digest goes out once a day at 5pm server time.
- **Game news emails.** Staff announcements and application emails will be added when those features are built (steps 4 and later).
- **Browser pop-ups** are set on the new Notifications page in the Menu. A Chapter doesn't pop up the first time the browser sees it, so logging in doesn't bring a flood of old news.
- **Mail service.** Emails send once the chosen service's details are in Kamal secrets (`SMTP_ADDRESS`, `SMTP_PORT`, `SMTP_USERNAME`, `SMTP_PASSWORD`, plus `MAIL_FROM` and `APP_HOST`). Until then, nothing is sent.
- **Password reset** is built now, since email is ready. The link works for 15 minutes.

## 2026-10-14: Who plays which character is a game setting

Each game decides whether a character's player is shown to everyone or only to staff (owner). Either way, anyone can send a Message "to the player of" a character, and in staff-only mode that doesn't reveal who the player is. Staff always see who plays what.

When players are hidden, the reply to a "to the player of" Message comes back as "from the player of" that same character, so the replying player's account and other characters stay hidden too (owner). The whole conversation stays tied to that character.

New games start with players hidden (staff only), to serve the anti-clique aim (owner). Built with Messages (step 3b) and profiles (step 4).

---

## 2026-10-14: Step 2 details picked while building

Defaults picked by Claude while building Chapters. Any of them can change.

- Posting out of turn (after "Post anyway") doesn't move the turn on; it stays with the player who was up.
- Turn order is the order characters joined. The first Passage of a new Chapter can come from anyone.
- Joining a Chapter from another Setting walks the character there first ("Travel here and join"), to match starting where you stand.
- Private Chapters: only characters in them or invited can read them. Any character in a Private or Hidden Chapter can invite others by name.
- Tabs show the Chapters of all the player's characters, labelled with the character when there's more than one.
- Arrival and departure lines skip idle Chapters.
- Characters without an icon show their first initial. Requiring an icon waits for character approval (step 4).
- Settings that sit directly in a top-level Area (like a starting Setting) show their latest open Chapter under the Area's banner on the front page.


## 2026-10-14: Making the grid feel physical (step 2)

- **Arrivals and departures:** when a character walks into or out of a Setting, its Chapters show a line such as "Mira arrives from the Great Hall."
- **Start where you stand:** a new Chapter begins in the Setting the character is in, so players travel there first (Travel here makes that one click).
- A compass layout of Paths was considered and left for later.


## 2026-10-14: Private messages

Players need a way to message one another privately (owner). Placed as roadmap step 3b, after notifications exist in step 3.

Defaults picked by Claude: a message can go to one person or a small group, replies stay in one conversation, and a new message counts as activity for email and browser alerts.

Messages go from player to player and are out of character, like forum PMs, so all of a player's characters share one inbox (owner). They're simply called **Messages**.


## 2026-10-14: Alerts in the browser

Like AresMUSH, Inkwll alerts players inside the browser as well as by email (owner):

- **The browser tab changes** when there's something new: the tab title shows a count, such as "(3) Inkwll", and the small site icon (favicon) gets a dot. Built in step 2 with live Chapters, since it comes almost free with live updates.
- **Browser notifications** (the pop-ups in the corner of the screen) are optional. A player turns them on, and the browser asks their permission once. Built in step 3 with the other alerts, using the same events as the emails.

Players choose when browser notifications pop up (owner, 2026-10-14), much like the email levels:

- **All activity:** every new Passage in their Chapters.
- **Only when it's my turn:** as with email, this applies in Chapters with more than two players.
- **Only after X minutes:** a pop-up only if something new has sat unread for the number of minutes they choose, so a player who is actively reading isn't nagged.

Default picked by Claude: these settings control the pop-ups only. The tab count and favicon dot always update, since they're quiet. Default picked by Claude: browser notifications only arrive while the game is open in a tab, even a background one. Notifications with the site fully closed need extra setup and can come later if wanted.


## 2026-10-14: Email notifications for new activity

Players can opt in to emails about new activity, using the email address on their account. Off until the player turns it on. Each player picks one level:

- **Every time:** an email whenever there's new activity.
- **Only when I'm not logged in:** nothing while they're on the site.
- **Only after I've been away a while:** one email once they've been away for a number of days they choose.

Sign-up has a box to opt in (owner, 2026-10-14). Default picked by Claude: ticking it chooses "only when I'm not logged in", and players can change the level later.

Players can also tick **only when it's my turn** (owner, 2026-10-14). In a Chapter with more than two players, they're emailed only when their turn comes up, not for every Passage. Default picked by Claude: this works alongside the level above, so "only when I'm not logged in" plus "only when it's my turn" means a turn email only while they're away. In a two-player Chapter, or one with no turn order, they're emailed as usual.

What counts as new activity (owner, 2026-10-14): new Passages in Chapters the player's characters are in, their turn coming up, being @mentioned, staff announcements, and their character application being approved or returned.

Defaults picked by Claude: the emails cover the same events as the in-game alerts, so the two are built together in step 3. Several new Passages in the same Chapter are bundled into one email until the player visits, so a busy Chapter doesn't flood their inbox. Every email has a one-click link to turn them off.

The email includes the text of the Passages the player missed (owner, 2026-10-14), each with the character's name. Only Chapters the player can already read are included. Default picked by Claude: a long catch-up shows the 20 most recent missed Passages in full, then says how many more there are, with a link to read the rest in the Chapter. Sending email needs a mail-sending service, set up in step 3 rather than waiting for step 11.


## 2026-10-14: OOC chat folds away

The OOC chat sidebar can collapse into the right edge, leaving a slim "OOC" tab that brings it back. While folded, the tab shows how many new messages the player hasn't seen (owner, 2026-10-14). Default picked by Claude: it starts open, and each browser remembers whether the player left it open or folded.

## 2026-10-14: Character icons in Passages

Each character has one icon, shown beside every one of their Passages. Extra images, including animated GIFs, belong on the character's profile, not in Passages. Kept simple on purpose.

Each Passage shows the character's name and small icon, with a pop-up mini-profile or at least a link to the full profile, like the mini-profile column on the owner's forums (see the thread screenshots in `docs/design-references/`). Built in step 2; the mini-profile fills out in step 4.

Default picked by Claude: whether an icon is required is a game setting, on by default.

## 2026-10-14: Front page laid out like the owner's forums

Each top-level Area is a banner (its image, or a styled heading), like a forum category. The Areas inside it are listed beneath as boards, each with an image, a short description, the ▾ shortcuts and its latest activity. An Area with nothing inside it shows as a single board. Clicking a board opens its entrance Setting.

Latest activity must never show private or hidden Chapters.

The other elements of the owner's skins (see `docs/design-references/`) are planned for the steps that build them: latest activity with Chapters, the strong-colour default skin in Platform, the reference nav bar as wiki links in the Menu, and the IC date, weather and who's online with the IC clock.

## 2026-10-14: Front page shows Areas, each with an entrance

- The front page shows only the top-level Areas (image, name, description), not every Setting.
- Each Area has an entrance Setting, chosen by builders (or its first Setting). Opening an Area takes you to its entrance, and players walk the Paths from there.
- An arrow beside each Area's name drops down shortcuts to every Setting inside it, so getting somewhere is never too hard.
- The admin panel has its own tabs.

Why: encourage people to travel the connected grid for an old-school MUSH feel, without making it hard to reach where they're going. Still open: whether opening an Area or a shortcut moves your character there or only lets you look (see `roadmap.md`).

## 2026-10-14: The "Where" list

A "Where" page (like a MUSH's `where` command) shows where characters are. Settled so far: a public (joinable) Chapter is shown with a link to it, and private or hidden Chapters are never shown. For each character it shows the Setting they stand in, plus each public Chapter they've posted in recently, linked (for example: Wren, Great Hall, also in "Duel at Dawn" in the Forest).

## 2026-10-14: Tabs for several Chapters at once

When a character is in more than one Chapter, the roleplay view shows them as tabs so the player can switch quickly. Each tab should feel like being in that Chapter's Setting (its name, image and description, who is there).

A character still stands in exactly one Setting (the one whose "Here" list shows them), but can stay in Chapters set in other Settings. Each tab shows that Chapter's own Setting.

## 2026-10-14: A wiki, inspired by Wikidot

The game has a wiki where staff and players can put whatever information they like (rules, setting lore, plots, guides). Pages are written in Markdown. Pages can pull in live game content, such as characters, Manuscripts and Settings, for example a list of every character or Manuscript with a given tag.

Editing: any player can create and edit pages, and every page keeps its full history so changes can be undone. Staff can lock a page (such as the rules) so only staff can edit it.

Build order: near the end, just before Platform, so everything it can pull in already exists.

## 2026-10-14: Images and text for descriptions

- **Areas and Settings** can be described with an image only, an image and text, or text only. Pages simply show whatever staff filled in.
- **Characters** can have the same mix. Each game decides whether a character must have a written description, an image, both, or neither.

Areas and Settings get this in step 1b. Characters get it with profiles in step 4.

## 2026-10-14: Banning

Staff need to be able to ban:

- **Accounts:** a banned account can't log in, and none of its characters can play.
- **IP addresses:** nobody can log in or sign up from a banned address.
- **Known VPNs (optional):** a switch to block known VPN addresses, for when the game is being brigaded.

Defaults picked by Claude: Scribes and Wellkeepers can ban (matching the earlier report decision); a ban can be permanent or end on a date; each ban records who made it and why; the VPN block is off unless staff switch it on.

VPN list: the game downloads a free, community-kept list of VPN and data-centre addresses once a day (no paid service). A paid lookup can be added later if brigades get past it.

## 2026-10-14: One install per game

Each game is its own copy of Inkwll with its own database. The owner may run several of their own games at once, sharing one DigitalOcean server through Kamal. Inkwll does not host other people's games: anyone else who wants a game runs it on their own server.

Why: the owner doesn't plan to host others, and separate installs keep each game's data and settings apart without building multi-game support into the code.

## 2026-10-14: Areas group Settings, and nest

Settings are grouped into **Areas**, and Areas can nest inside each other as deep as a game likes. Example: Hogwarts (Area) holds Castle, Grounds and Forest (Areas); Castle holds its floors (Areas); each floor holds rooms such as the Entry Hall and Great Hall (Settings).

- Characters are never "in" an Area, only in a Setting. You are in the Great Hall, not in the Castle or the First Floor.
- The homepage shows the list of top-level Areas. Opening an Area shows the Areas and Settings inside it.

Defaults picked by Claude, confirmed by the owner on 2026-10-14: every Setting belongs to exactly one Area, and Paths can link Settings in different Areas.

## 2026-10-14: Layout puts the roleplay front and centre

Don't copy AresMUSH's layout too closely. The roleplay itself (Settings, Chapters and their Passages) is the main thing on screen, laid out more like a forum. Extras such as rules, plots and other reference pages are reached through the menu.

## 2026-10-14: The first game stays setting-neutral for now

Sample content (the default starting Setting, starter Skills, example Boons and Banes) stays generic. The owner can describe a setting later.

## 2026-10-14: Skins start as CSS

A skin changes colors, fonts and extra CSS, set from the admin panel. Swappable page layouts can come later, once we know which pages need them.

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

Who can read what: each game marks every profile and application field public or private. Private fields are seen only by the player and staff. A text description is optional and each game can switch it on or off, because many games will use images instead, so profiles also need image fields.

Note for the build: uploaded images are stored on the server's disk. The nightly database copy doesn't include them, so the deployment step must make sure images are backed up too (the droplet backups do cover them).

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
| area (group of rooms) | **Area** for now; the owner wants to revisit a themed word later |
| pose | **Passage** |
| exit | **Path** |

Only the words players see change. The code keeps the plain words (room, scene, pose), and the visible words live in one wording file so a game can swap them for its own.

## 2026-10-14: Players can edit their poses until the scene finishes

A player can edit their own poses any time before the scene finishes. Edited poses show an "edited" mark. Staff can still see the original, so reports show what was really posted. Once the scene finishes, poses are locked.

Default picked by Claude, confirmed by the owner on 2026-10-14: deleting works the same way, and leaves a "pose removed" note in its place.

## 2026-10-14: The 3-pose rule needs four players

A scene can only use the 3-pose rule when it has at least four players. Smaller scenes pick turn-based or free-for-all.

Default picked by Claude, confirmed by the owner on 2026-10-14: if a 3-pose scene drops below four players, it switches to turn-based until it has four again.

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

Defaults picked by Claude, confirmed by the owner on 2026-10-14: the game sets the default and each scene's creator can change it; the 5-minute timer is adjustable per scene; clicking "I'm here!" starts a fresh 5 minutes.

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
