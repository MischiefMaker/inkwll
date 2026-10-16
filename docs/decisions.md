# Decisions

Every choice the owner has settled, newest first. Each entry says what was decided and, where it helps, why.

Only things the owner decided go here. Ideas that still need the owner's yes are marked **[Proposed]** in `design.md` until they are settled.

To add one: copy an entry, put it at the top, and fill in today's date.

## 2026-10-16: Chapter page and Directory tidy-up (owner)

- Every Chapter gets a permanent number, counted in the order Chapters were started, shown at the top as "Chapter 12". It stays when the Chapter becomes a Manuscript.
- On wide screens the Place, who's in the Chapter and the writing tools (Roll a Skill, spells, Storyteller tools) sit in a column to the right of the story. On narrower screens the Place stays at the top, with its Paths listed on the right.
- The writing box is more compact: whose turn, "Writing as" and the kind of post share a row, and the box is smaller.
- Storytellers and GMs don't get a card in the cast at the top of a Manuscript Chapter.
- The Character Directory's first tab is **Active**: approved characters being played, without the roster. The group tabs come next, then the Roster and Unapproved tabs set apart.

## 2026-10-16: Lock the Game and Inkling names (owner)

- Wellkeepers have a red **Lock the Game** button on the admin page. While locked, guests and non-staff players see a "locked" page instead of the game; staff can still use everything. Log in, log out and password reset stay reachable.
- Inklings pulled in from an application are titled "Name's First Goal" and "Name's First Secret". Inklings players start themselves keep their own titles.
- Character profile tab groups are separate blocks stacked down the page, not one row.

## 2026-10-15: Chapter layouts (owner)

- Each game picks how a Chapter page looks in Admin → Look: **Manuscript** (the default; reads like a page from a book), **Forum** (each Passage is a post with a portrait, name and details beside it) or **Chat** (the earlier look).
- Paragraphs don't start with the character's name, because poses don't always begin with it. The name sits above the Passage or under the portrait.
- Manuscript has two separate settings: the cast under the title (large cards or small row) and the picture beside each Passage (large or small). Defaults: large cast, small picture.
- Why: so Chapters look less like AresMUSH scenes. Mockups in the "RP forum and host research" thread.

## 2026-10-15: Launching and updating Wells (owner)

- A Founder-only Admin → Wells page starts and updates Wells. Only the Founder flag sees it.
- Its buttons ask GitHub to run the Deploy workflow; the game never runs Kamal itself. The game holds only a GitHub token that can run workflows and read the code; the droplet SSH key and the DigitalOcean token stay in GitHub's secrets.
- Update offers only versions Claude has marked ready (GitHub Releases), never whatever is on main. Each update backs up the database first, and an earlier version can be put back.
- inkwll.com's DNS moves to DigitalOcean so subdomains can be made automatically. The domain stays registered at Namecheap.
- Built in four steps, each with the owner's go-ahead. Details in `docs/wells.md`.

## 2026-10-15: "Page" staff level renamed Steward (owner)

- The lowest staff level, flagged staff (formerly "Page"), is called **Steward**, because "Page" was confusing next to web pages, wiki pages and character pages.
- Display-only: the code keeps its plain names and games can still rename it. Founder, Wellkeeper and Scribe are unchanged.

## 2026-10-15: Brevo sends the game's email (owner)

- Password resets and notification emails go out through Brevo (free for 300 emails a day, plain SMTP). No mail server on the droplet: mail from it would mostly land in spam.
- The game already reads SMTP_ADDRESS, SMTP_PORT, SMTP_USERNAME and SMTP_PASSWORD from Kamal secrets; nothing in the code changes. Setup steps are in `docs/email-setup.md`.
- Namecheap already has one SPF record; Brevo's include is merged into it, never added as a second record.

## 2026-10-15: Natural Magic (owner)

- The Spirit Skill "Natural" is renamed "Natural Magic" (starter set and existing games, unless staff already renamed it).

## 2026-10-15: Active Chapters tab (owner)

- A character's profile has an Active Chapters tab, shown only to their player and staff. Staff see only Chapters they may already see (hidden ones only when reported, as before).

## 2026-10-15: GM in Writing as (owner)

- The Writing as switcher above the Passage box also offers GM to staff and Storytellers, with the same warning as other characters not yet in the Chapter. Joining as GM makes you Storyteller there.

## 2026-10-15: Age beside Passages, icons in menus (owner)

- **Age separate from Birthday:** a Birthday profile field can show just the age ("Age: 27") beside a character's Passages.
- **Game icon:** each game can upload its own, shown small beside the name at the top left and larger in the front page header. The default is the favicon's inkwell.
- **Icons:** the front page's "[Character] is in [Place]" line and the Playing as menu show the character's icon, with the name in the Group colour.

## 2026-10-15: Roster section and retiring roster characters (owner)

- **Admin → Characters:** sections Approved, New (no approved character yet), Roster and Retired, each collapsible.
- **Retiring a roster character** removes it from the roster. Staff can put it back.

## 2026-10-15: Paths grouped by Streets first (owner)

- **Paths:** shown broken out with Streets first, then the other types (Buildings, Outdoor areas, Other places). Streets are what will make up the v2.0 mini-map; buildings and outdoor spaces generally sit on streets.

## 2026-10-15: Locked fields, Place types, tabs (owner)

- **Player can edit:** each profile field has a "Player can edit after approval" setting. Unticked fields (Background by default) are locked for non-staff once the character is approved. Staff can always edit.
- **Place types:** Nothing special, Building (with separate units), Building (no units), Street (any kind) and Outdoor area (parks, squares). Dormitory, hotel and office block are gone (existing ones became buildings with separate units). "Ordinary" is now "Nothing special".
- **Menu:** entries use Title Case by default; "My player profile" is "My Profile".
- **Front page:** the Area list is centred, for guests and players alike.
- **Chapter tabs:** can be folded away, with an animated quill when folded and it's your turn. Finished Chapters' tabs can be closed with an X. The OOC Chat is shortened to fit under the tabs.
- **All Places** is grouped by Area.
- **Writing as:** the Passage box has a character switcher; picking a character who isn't in the Chapter warns first.
- **Admin → Characters:** retired characters sit in a separate section at the bottom.
- **Roster:** putting the character you are playing on the roster moves Playing as to your next character. Roster characters who were played before are marked.

## 2026-10-15: Starter content, Description and Picture fields (owner)

- **Ship with defaults:** new games get SOUL's Aspects and Skills from ares-soul-plugin, plus a starter Boons and Banes catalogue and starter profile fields. The plugin has no Boons and Banes list, so Claude wrote the starter one.
- **Description is not built in:** it is an ordinary, optional profile field that games can rename, remove, require or make a Picture.
- **Picture answers:** profile fields have a Picture kind of answer, for games that use images instead of text for descriptions.
- **GM in Playing as:** staff and Storytellers can post and run Chapters as their player (named after the player, Storyteller in Chapters they start). GM is not physically anywhere: never in Where or Here, only listed in Chapters, as Storyteller.
- **Settings are renamed Places** (owner picked it from Place, Locale, Location): "Setting" was confusing next to account settings, and Places matches My places.
- **Fields that start Inklings:** a profile field can be set to start an Inkling (Goal, Secret and so on) from its answer when the character is approved. Goals and Secrets do by default. Only for characters approved from now on; the player owns the Inkling and staff don't see it until it is sent.
- **Staff notifications:** work waiting on staff (applications, roster requests, SOUL requests, Inklings, reports) shows in the bell with the unread alerts, for the staff whose jobs cover it. In-app for now; email for staff is not built.
- **SOUL rating guide:** an "i" on the SOUL sheet opens a pop-up of what each rating range means (ordinary to superhuman). Staff set the ranges and wording in Admin → SOUL, not in a config file. Explanation only: it changes no rolls.
- **Pencil and trashcan everywhere:** short Edit, Delete and Remove links and buttons are icons (the word stays for screen readers and on hover). Longer ones such as "Delete this thread" keep their words.
- **Directory tabs:** All, one tab per character group, Roster, and Unapproved (staff only).
- **Menu sections:** your own things together (My characters, Chapters, places, Inklings, player profile), then the world, then community and help, then staff.
- **Alerts bell:** opens a small drop-down over the current page, not a whole new page.
- **Online now lists players** (by player name); **Where lists characters**.
- **Deleting Boons and Banes:** staff can delete catalogue entries (pencil and trashcan buttons). Entries characters hold are retired instead, so sheets keep them.

## 2026-10-15: Default icons, banners and favicon (owner)

- **Favicon:** a slate inkwell and quill on a gold circle (option D of four).
- **Players and guests** without an icon picture get a pen-nib icon on a round badge in the look's colours (gold and slate by default), instead of their initial. Guests get a grey one.
- **Areas, Settings and boards** without an icon picture get a drawn icon tile (compass, door, speech bubble). Areas and Settings without a banner picture get a plain drawn banner (owner: "I think" we should; open to dropping it).
- Icons are line drawings in the code (`app/helpers/icons_helper.rb`), drawn like the header's bell. No outside icon sites.

## Preparing roster characters (owner, 2026-10-15)

- Adding a roster character from Admin → Roster takes staff to its profile. It stays hidden from players ("Being prepared") until staff fill in SOUL, background and the rest and press **Open on the roster**.
- Staff who review applications (Scribes, Wellkeepers, Pages with the app flag) can **edit** roster characters, both being prepared and on the roster.

## The Prologue: an OOC starting Setting (owner, 2026-10-15)

- New characters start in an out-of-character Setting instead of an IC one. Claude picked the name **The Prologue** (owner suggested "Waiting in the Wings" or something bookish), in a new top-level Area, **Out of Character**, listed last on the front page. One-way Paths named after each top-level Area's entrance Setting lead into the story. Rename or move it from Admin → Building; whichever Setting is ticked as the default starting one is where new characters begin.

## What guests can read (owner, 2026-10-15)

- Guests can **read** much more of the site: the Boards, the Wiki, Where, the character directory and Roster, character and player profiles, All Settings, the Archives and Chapters anyone may watch (open ones, finished private ones, and hidden ones made public). They can't post, edit, join or message; those send them to log in. Their own-pages (My characters, Messages, My Chapters) still need an account.
- The guest top bar has a Menu with everything they can read, and the front page shows the Boards to guests.

## Area banners on Settings (owner, 2026-10-15)

- Each Setting shows its own Area's banner and short text (if it has them) at the top, above the Setting's name and description. It's the nearest Area only, not the ones above it. Areas with neither show nothing extra.

## OOC Chat moderation (owner, 2026-10-15)

- **Players** can edit and delete their own OOC Chat messages; **staff** can edit and delete anyone's.
- Changes leave a note: "(edited)" (or "(edited by staff)"), and a deleted message shows as "Deleted" or "Removed by staff". The original words are kept in the database for staff's records.
- **Staff can block someone from posting in the OOC Chat**, temporarily or permanently. Built as a chat-only ban on the Bans page (players by account, guests by address), so it's for staff who can ban (Scribes and Wellkeepers). Blocked players still log in, play and read the chat.

## Testing tweaks (owner, 2026-10-15)

- **Headings** in the default look (Slate blue and gold) use a sans-serif font, not Georgia/Times.
- **Log in and the OOC Chat page** keep the front page's top bar and OOC Chat layout, so visitors can always navigate away.
- **Guests see the OOC Chat beside every page** (when guest chat is on): it's how the game welcomes guests and answers their questions. Log in and sign up say "Feel free to say hello in the OOC Chat" instead of linking to a separate chat page.
- **Tweaks go on a branch** and ship with the next deploy of a major fix, not on their own.

## Code audit follow-ups (owner, 2026-10-14)

- **Weekly XP** goes only to approved characters being played. Retired characters and those on the roster get none, and don't count towards the catch-up median.
- **Private Chapters** follow the Hidden rule: one player can't open one up (switch it to Open) alone. It becomes public once every player agrees, using the same "I agree to make it public" button. Making a Chapter more closed (Open to Private, Private to Hidden) is still fine.
- **Renamed wiki pages** remember their old addresses, and old links redirect to the new one. A new page that takes an old address wins it.
- **Daily digest emails:** if one player's email fails to send, the failure is logged and the others are still sent. The failed one is tried again next time.

## Long Chapters show their latest posts live (owner, 2026-10-14; number picked by Claude)

An open Chapter's page shows only its latest 50 posts and updates live. Above them, "Read the whole chapter (N earlier posts)" opens every post on a page that doesn't update by itself, with a link back to the live page to post. Finished Chapters (Manuscripts) always show everything. This keeps long, busy Chapters quick on a small server. The number is `Scene::LIVE_PASSAGES`.

## Inklings belong to the character (owner, 2026-10-14)

When a character changes hands through the roster, its Inklings go with it, secrets included, so the new player knows what the character knows. This matches the AresMUSH Inklings plugin, where the character is the login, so everything moved with it and players were warned that personal entries "may become visible under game policies (character transfers, roster changes, or administration)". In Inkwll, personal notes belong to the player who wrote them, so the old player's personal notes stay private to them.

## Staff password reset links, for players with no email (owner asked, 2026-10-14; details picked by Claude)

The "email required" game setting already existed (on by default). The owner asked for games to be able to make email optional, so the missing half was built: staff (Scribes and up, for players they can manage) open a player in **Players and staff** and press **Make a password reset link**. The link is shown once for staff to send privately (for example in Messages), works for one day, and stops working once used. The setting's hint now says what a player without email misses: resetting their own password and email notifications. Alerts and browser pop-ups still work.

## Guests can preview the grid (owner, 2026-10-14; details picked by Claude)

Visitors who aren't logged in get **Preview** on the front page instead of Enter, so they can still look around. They're listed under a Setting's "Here" as **Guest**, or **3 Guests** for more than one (owner).

Defaults picked by Claude, for the owner to check:

- **What guests can see:** the front page, Area pages and Setting pages, with a small top bar ("Previewing as a guest", Log in, Sign up). Paths are links, so guests can walk around and look. They see the list of open (not hidden) Chapters in a Setting but need to log in to read one. Everything else (Chapters, profiles, the directory, the wiki, Boards) still asks them to log in, and the Boards section is left off the front page for them.
- **Counting guests:** a guest counts in the last Setting they looked at, for 10 minutes. Search engines and link previews aren't counted. Others in the Setting see the count change live when a guest arrives.
- **Banned addresses** can't preview; they're sent to the log-in page with the ban message.

## Enter, Look and an Area's default Setting (owner, 2026-10-14)

- On the front page, every Area with Settings has an **Enter** button (no more "Look in"). Enter physically moves the character you're playing as to the Area's default Setting (owner). Players without a character are asked to make one first.
- The **default Setting** is picked with a tick box, "Default Setting for its Area", on the Setting's edit page (also still a menu on the Area's edit page). Until one is ticked, it's the first Setting made in the Area (owner).
- An Area with no Settings shows **Look** instead, which opens the Area's overview (owner).
- The Shortcuts open a Setting's page, where **Travel here** moves the character (owner).

## Apartment-style Settings with numbered Paths (owner, 2026-10-14; details picked by Claude)

The owner asked for special Settings like apartments: a main room with sub-rooms off it, reached by numbered Paths shown simply so a room can have lots of them ("100 - Jaxon Marley").

Defaults picked by Claude, for the owner to check:

- **Setting types:** each Setting has a type, picked on its edit page: Ordinary (the default), Apartment building, Hotel or inn, Dormitory, Office block, or Street of houses. The type names the numbered list ("Apartments", "Rooms", "Dorm rooms", "Offices", "Houses") and what new numbered rooms are called ("Apartment 100").
- **Numbered Paths:** any Path can have a number (letters, numbers, dots and dashes, like 101 or 2B). Numbered Paths sit in their own compact list under the ordinary Paths, in number order, in columns, as "100 - Jaxon Marley". An Ordinary Setting with numbered Paths calls the list "Doors". They're left out of the compass.
- **Long lists:** more than 12 doors adds a "Find a number or name" box that narrows the list as you type.
- **Building them:** "Add numbered settings" on a Setting's edit page takes one line per room ("100 Jaxon Marley", "101 - Nestor Nash", or just "203"). Each line makes a Setting called "Apartment 100" in the same Area, the numbered Path to it, and a Path back out (called "Out" unless the builder names it). Up to 100 at a time; if any line has a problem, nothing is saved.
- **Keeping lists tidy:** Settings behind a numbered door don't appear in their Area's list or the front page Shortcuts, so a block of 50 flats doesn't flood them. They're reached from their building.
- **In a Chapter:** the Chapter's Setting box keeps the ordinary Paths as buttons and folds the numbered ones into a small "Apartments (18)" drop-down.

## Path types: streets, buildings and units (owner, 2026-10-14)

- Every Path has a type. **Streets** are the ordinary ways between places and can point a compass direction. **Buildings** are things to go into from a street; a Setting lists them under "Go in", by name, because a street usually has several. **Units** are numbered doors like apartments (a Path with a door number), shown in the compact numbered list.
- The usual way back from a building or unit is **Out**, a direction of its own. "Add the way back" makes it automatically, and when the compass is on, Out sits in its middle.
- The headings and type names are in the wording file (`config/locales/en.yml`, `exit_kinds` and `exit_kind_names`), so games can rename them.
- The mini map waits for Version 2.0.

## Path directions and a compass (owner, 2026-10-14)

Paths can optionally point one of the 16 compass directions (N, NNE, NE ... NNW). A Path with a direction but no name is named after it, and "Add the way back" points the opposite way (NNW comes back SSE). Paths are listed clockwise from north. Games can switch on a compass (Admin, Features) that shows each Setting's directional Paths around a compass rose; it's off by default.

## An old-school MUSH look (owner, 2026-10-14)

A ready-made look in Admin, Look: white Courier text on black, with the classic ANSI colours for context (character names yellow, Paths green as <Path>, OOC magenta, links and buttons cyan, section titles yellow between blue -=[ ]=- marks). Its extra styling is in `app/assets/stylesheets/skin-mush.css`, and its colours are CSS variables (`--ansi-yellow` and so on) a game can change.

## A simpler, less forum-like look (owner, 2026-10-14)

- The layout was feeling too much like a forum. The front page now shows the game's name, large, with a paragraph or two about the game under it (both set in Admin, Game settings).
- Below that it just lists the top-level Areas. Each has an **Enter** button that takes the character to the Area's entrance Setting. Shortcuts straight to Settings still exist but are tucked into a small "Shortcuts" fold, so players get around by walking the Paths.
- On a Setting's page, its Paths and who's here sit right under the description, above the Chapters. "Travel here" stays for Settings seen from afar (owner chose this over removing it).
- The default skin stays very simple but customisable. Areas and Settings can each have any of: a small icon, a large banner, a page background, short text and long text. A Setting without a background uses its Area's.
- Lots of room for customising: Admin, Look takes a background picture for the whole page, one for boxes and panels, and one behind the game's name on the front page. Everything else is still reachable with extra CSS.

## 2026-10-14: Forum boards (owner, details picked by Claude)

The owner asked for a place for things that work better in a forum than a chat (advertising, wanted ads, news), customizable along with who can start threads and reply, placed after the Areas on the front page and styled a lot like them.

Defaults picked by Claude, for the owner to check:

- **Names:** players see "Boards", "Threads" and "Posts" (changeable in `config/locales/en.yml` like the other themed words). The code calls them forum boards, topics and posts.
- **Starting boards:** News (staff start threads, anyone replies), Advertising and Wanted ads (anyone starts and replies).
- **Who can post:** each board picks, separately for starting threads and replying: anyone with an account, staff only, Scribes and Wellkeepers only, or (replies only) nobody.
- **Reading:** anyone with an account, like the rest of the game. Guests can't see boards.
- **Who sets them up:** Scribes and Wellkeepers, under Admin → Boards (in "Game world"). Each board has a name, description, order, small icon and large banner, like an Area card. Deleting a board deletes its threads.
- **Posts are out of character**, shown under the player's name and picture like the OOC Chat, not a character's. Written in Markdown, made safe the same way as the wiki.
- **Moderation:** writers edit their own posts (marked "edited"); a thread's starter can rename it. Scribes and Wellkeepers can pin a thread to the top, lock it (no more replies except from them), delete a thread, and delete or edit any reply.
- **Pages:** 30 threads or posts per page.
- **Left for later:** "new" markers and alerts for replies, reporting a post, and letting writers delete their own posts.

## Admin panel uses a side menu (owner, 2026-10-14)

The admin panel had too many tabs. It now has a grouped menu down the right-hand side, like Jcink's admin CP, and the OOC Chat folds away while you're in the admin panel (it comes back as you left it when you return to the game). On phones the menu folds into one button at the top.

## Guiding principle (owner, 2026-10-14)

Keep forum RP's easy navigation and many Chapters at once, but make the grid feel real and physical, like moving through space on a traditional MU. AresMUSH has lost much of that feeling and some games no longer build grids; Inkwll should not. When a design choice trades one against the other, protect the feeling of physical space.

## Design aim: keep cliques to a minimum (owner, 2026-10-14)

Old-school MUSHes kept cliques down partly because nobody knew who played which character. Inkwll should keep that spirit where it can, while still making it easy to reach a character's player out of character.

Players who want a separate identity for an alt can make a second player account.

## 2026-10-14: Launching on the IP address, deployed from GitHub Actions (owner)

- The game launches on the droplet's IP address with no domain for now (owner). That means plain http, so only testers until there's a domain. The droplet is the $6/month 1 GB one with backups on.
- The game's domain is inkwll.com, registered at Namecheap (owner, 2026-10-15). It serves over HTTPS, and www.inkwll.com redirects to inkwll.com.
- Deploys run from a "Deploy" workflow in GitHub Actions that only runs when started by hand (owner), because Claude's cloud environment can't open SSH connections. Its secrets live in the repository's Actions secrets. Claude asks the owner before each run. See `docs/deploying.md`.

## 2026-10-14: Storyteller tools (owner)

Storytellers who aren't staff can use the GM roll tools, and they can suggest awards, which need staff approval (owner). This confirms the earlier "What Storytellers can do" entry.

Built as a "Storyteller tools" box in any Chapter where you're the Storyteller:
- **Call for a roll** from a player in the Chapter: it waits like a roll the player asked for, and the Storyteller picks the Boons and Banes that count and rolls it. Storytellers never judge their own characters' rolls.
- **Players' Aspects and Skills:** the other players' ratings, and nothing else from their sheets.
- **Suggest XP:** 1 to 10 XP for one of the other players, with a reason. It goes to Admin → SOUL requests, and nothing is given until App staff approve it. It also works after the Chapter is finished.

## 2026-10-14: New games start in Slate blue and gold (owner)

New games start with the "Slate blue and gold" look. The ready-made looks, plain included, stay as templates the admin picks from when launching a new game (owner).

Built as: a new game's settings start in Slate blue and gold. Until a Wellkeeper saves a look, the admin Overview shows "Pick your game's look" with a link to Admin → Look, where the look in use is marked.

## 2026-10-14: Roster take-overs are configurable (owner)

Each game chooses how a new player takes over a roster character: redo all of the application, redo some of it or answer extra questions, or simply claim and play (owner).

Built as:
- **Claim and play** (Game settings, off by default): the character becomes the player's straight away, with no staff review. Two people can't claim the same one.
- **Redo the whole application** (Game settings, off by default): after a take-over, the character goes back to a draft that the new player sends to staff for approval.
- **Redo some, or extra questions:** any Profile field can be ticked "Ask again when someone takes a character from the roster". Those questions appear on the apply or claim form, staff see the answers, and the new answers replace the old player's.
- These can be combined, for example claim and play plus a couple of questions.

## 2026-10-14: Step 10 details picked while building (Platform)

Defaults picked by Claude, for the owner to check:

- **Admin → Features** (Wellkeepers) gathers the on/off switches: SOUL, Inklings, Grimoire, the wiki (new, on by default) and guest chat. They moved there from Game settings. The switches stay columns on the game settings table rather than a separate features table, since that's how each system was already built.
- **Admin → Look** (Wellkeepers): a colour picker for each of the stylesheet's nine colours, in light and dark, fonts for text and headings, and an extra CSS box. Only colours that differ from the built-in ones are saved.
- **Dark mode:** on by default, as now. A game can switch it off so everyone sees its light colours.
- **Ready-made looks** after the owner's forum skins: "Black and red" (Falls the Shadow), "Slate blue and gold" (Last Call of the Wild) and "Black and white" (What's Left of the Flag), plus "Inkwll plain". They use fonts already on people's devices. The owner later picked Slate blue and gold as the default (see above).
- **How it's served:** the skin is its own stylesheet at /skin.css, loaded after the built-in one, so nothing typed on the Look page is mixed into page HTML. Fonts can only hold letters, numbers, spaces, commas, hyphens and quotes, and colours must look like #5b3f8c. Extra CSS is trusted, because only Wellkeepers can write it. Web fonts work with @import in the extra CSS.
- **Left for later:** the swappable page templates in Version 2.0, and the roster getting its own on/off switch.

## 2026-10-14: Step 9b details picked while building (Wiki)

Defaults picked by Claude, for the owner to check:

- **Who can read and write:** anyone with an account. Guests can't see the wiki.
- **Markdown** is turned into pages by the commonmarker gem (no extra hosting). Raw HTML in a page is dropped and links are cleaned, so nobody can add scripts. Tables, strikethrough and pictures from a web address work.
- **Linking pages:** `[[Page name]]` or `[[Page name|words to show]]`. A link to a page nobody has written yet offers to start it.
- **Live lists:** a line on its own like `{{characters group="Ravens"}}`, `{{characters roster}}`, `{{character name="..."}}`, `{{manuscripts setting="..." label="..." limit=5}}`, `{{settings area="..."}}` or `{{pages tag="lore"}}`. Manuscripts only lists Chapters the reader is allowed to see.
- **History:** every save is kept, with an optional "what did you change". Anyone who can edit a page can put an old version back, which is saved as a new version so it can be undone too.
- **Locking:** any staff member can lock or unlock a page; then only staff can change it.
- **The Menu:** "Wiki" is in the Menu. Staff give a page a "place in the Menu" number to list it there too (for example the rules).
- **Deleting** a page and its history: Scribes and Wellkeepers only. Everyone else can blank a page, which history can undo.
- **Tags** sort pages, and the wiki list filters by tag and searches titles and text.

## 2026-10-14: Step 9 details picked while building (Grimoire)

Rebuilt from github.com/MischiefMaker/ares-grimoire-plugin on top of SOUL. Defaults picked by Claude, for the owner to check:

- **Off by default.** Game settings has "Use Grimoire"; it also needs SOUL on. Admin → Grimoire appears once it's on.
- **Branches** are set up in the admin panel rather than a file: a name, a description and the SOUL Skill used to learn and cast its spells. The game adds those Skills under SOUL (for example "Hedgecraft"). A branch with spells can't be deleted.
- **Spells** have a branch, a name, a description, the Skill rating needed, and a SOUL difficulty to cast against. Staff retire spells rather than delete them, so characters keep what they learned.
- **Learning** costs the needed rating times 1 XP (the plugin's default; changeable in `config/grimoire.yml`), from the Grimoire tab on the character, once the SOUL sheet is finished. It shows on the XP ledger and in Narrative History.
- **Casting** is a "Cast a spell" box in Chapters, next to "Roll a Skill": a roll of the branch's Skill against the spell's difficulty, with Boons and Banes for that Skill counting. It posts like any roll.
- **Proposals:** players propose a spell from the Grimoire tab; App staff approve (which creates the spell, editable afterwards) or reject with a reason. The player still learns it with XP.
- **Who manages it:** App staff (Scribes, Wellkeepers, App Pages), the same as the Boons and Banes catalogue.

## 2026-10-14: Step 8 details picked while building (Inklings)

Rebuilt from github.com/MischiefMaker/ares-inklings-plugin, keeping its rules: drafts are hidden from staff, sending to staff locks the Inkling, only approving or asking for changes unlocks it (a staff reply never does), approving a round isn't the end, and closing is. Defaults picked by Claude, for the owner to check:

- **Types** come from the plugin (Initiative, Request, Pitch, Goal, Secret, Progress; staff types Hint, Vision, Nudge, Hook) and live in `config/inklings.yml`, where each game can change them.
- **Where:** "Inklings" in the Menu lists your characters' Inklings and those shared with you, with a "New" marker. Admin → Inklings (App staff) shows those waiting for an answer, then the rest. Staff start one for a character from that character's profile. New entries ring the alerts bell.
- **Entries:** an update everyone with access sees, private (you and staff; staff can address one character), a personal note (only you, not even staff) or a staff note (staff only). Each is numbered like 14.3. Personal notes can be added even while it's locked.
- **Sharing** with characters by name or with a whole character group. They can read and write in it, but not private or personal entries.
- **Rolls** are SOUL rolls by the Inkling's character (or a character it's shared with), shown to everyone or only to staff.
- **Rewards** (staff): XP, a new Boon or Bane, progressing one the character has, a Culmination, or a written note. They go through SOUL and its staff log, and show to the player only unless staff tick "everyone".
- **Switch:** Game settings has "Use Inklings", on by default.
- **Left for later:** the plugin's Secret and Goal drafts during character creation (games can add those as Application fields for now), bonus XP for Progress entries, search, asking staff to delete one, and email for Inkling activity.
- **Storyteller tools** were built later the same day, once the owner said what they should be (see "Storyteller tools (owner)").

## 2026-10-14: Step 7 details picked while building (IC clock)

Defaults picked by Claude, for the owner to check.

- **Each Chapter has its own date,** plus an optional time of day in words ("Late evening"). A new Chapter starts on the game's date unless its starter picks another.
- **Moving a Chapter's date:** any player in the Chapter can change it in the Chapter's settings, and the Chapter gets a line such as "Wren moved the chapter to October 15, 1526, Morning." so everyone sees. There's no vote; players can talk it over first, and staff can see the line if there's a dispute.
- **Where it shows:** at the top of the Chapter, in the Setting's Chapter list, in My Chapters and on Manuscripts in the Archives.
- **Front page:** "It is (the game's date)." with today's weather, which staff type in Game settings (optional, free text). At the bottom, "Online now" lists the characters being played by everyone seen in the last 10 minutes, linking to the Where list. Players are not named, to keep the no-cliques aim.
- **Dates before 1582** use the modern calendar throughout, so historical games get consistent dates.
- Seasons, moon phases and automatic weather are left for later.

## 2026-10-14: Step 6c details picked while building (Jcink add-ons)

Defaults picked by Claude, for the owner to check.

- **Beside Passages:** the character's group, plus any public profile field ticked "Show beside Passages" under Admin → Profile fields, shown in one short line next to the name and in the mini-profile pop-up. A birthday field shows as an age.
- **Groups:** Wellkeepers make them under Admin → Character groups, each with a name colour. Players pick a group on the character form until their character is approved (always, in games without approval). After that, Wellkeepers change it in Admin → Characters. The colour shows on Passages, the mini-profile, the Here list, the profile and the directory, which can also filter by group.
- **My Chapters** (in the Menu) is only for the player: each of their characters with every open Chapter, its Setting, whose turn it is, and who posted last and when.
- **Alerts bell** (in the header): a new Passage in your Chapter, your turn, an @mention, and a Chapter you were in being finished. Several new Passages in one Chapter make one alert with a count. Opening the Chapter or the alerts list marks them read. Read alerts are deleted after 30 days. Messages keep their own count and don't use the bell. Alerts come whatever the email settings are.
- **Subtitles and labels:** any Chapter can have a one-line subtitle. Wellkeepers define labels (for example content warnings) under Admin → Chapter labels; the players in a Chapter pick them when starting it or in its settings. Both show in the Setting's Chapter list and at the top of the Chapter.

## 2026-10-14: Step 6b details picked while building (Rosters)

Defaults picked by Claude, for the owner to check.

- **Where it lives:** "Character directory" and "Roster" are in the Menu. The Roster page is the directory showing only roster characters. Admin has a new Roster tab (App staff), with a count of what's waiting.
- **The idle checkbox** is on the character form under "If you stop playing", for every character (not only during the application). Idle means no Passage and no move for the game's roster idle days (90 by default, changeable in Game settings). The check runs once a day.
- **A character on the roster** belongs to a built-in "Roster" account nobody can log in to, and counts as retired until someone takes it over. It leaves its unfinished Chapters and invitations when it goes on.
- **Applying** is a short note, seen only by staff. A player can have one waiting application per character. When staff approve one, the others for that character are turned down automatically, and the new player gets an email if they asked for emails.
- **"Message the player"** is hidden on roster characters, since nobody plays them.
- **The new player's sheet:** if the SOUL sheet was never finished (for example a character staff made), the new player fills it in and presses "Finish my sheet". This also lets a player finish a sheet staff unlocked for them.
- **Staff can put any active character on the roster** from Admin → Characters, as well as approving a player's request on the Roster page.
- **Archiving an account** (Players and staff, for anyone you can edit): the player can't log in, is logged out everywhere, and their characters are retired, or go on the roster if they ticked the idle box. Archived accounts are greyed at the bottom of the list. The Delete button only shows to a Founder, and only for accounts that never had characters.

## 2026-10-14: Step 6 details picked while building (SOUL extras)

Defaults picked by Claude, for the owner to check. Numbers follow the SOUL plugin.

- **Boons and Banes catalogue:** starts empty. App staff (Scribes, Wellkeepers, App Pages) add entries under Boons and Banes in the admin panel, optionally tied to fixed Skills. Entries are retired rather than deleted.
- **Levels:** Minor (1), Major (2), Legendary (3). A Boon rerolls dice showing 1 up to its level; a Bane rerolls the high dice the same way. On a roll, every unresolved Boon and Bane tied to that Skill counts automatically, and the roll line names them.
- **Starting sheets:** players pick their own Boons and Banes while the sheet is open, within the plugin's Resonance limits. A character always needs one Bane for every two Boons, before and after approval.
- **After the sheet locks,** players ask staff for new ones with a reason, and staff approve or deny them on the new SOUL requests page. Staff can also grant, progress (a Boon grows, a Bane fades), regress, resolve (it stops counting but stays on record), restore or delete them.
- **The player's explanation** of each Boon and Bane is seen only by the player and staff, like the rest of the sheet.
- **Storyteller rolls:** in a Chapter with a Storyteller, players can tick "Ask the Storyteller to judge it". The Storyteller sees the waiting roll, picks the difficulty and which of the player's Boons and Banes count, and rolls it. The player can cancel while it waits. A Storyteller doesn't judge their own player's rolls.
- **Culminations:** players propose one (title and description) on the SOUL tab, and staff approve or deny it on the SOUL requests page. Approved ones show on the sheet, and staff can withdraw them later.
- **Narrative History:** a plain list on the SOUL tab of how the character changed: starting play, ratings raised, Boons and Banes gained or changed, and Culminations. Only the player and staff see it.
- **Staff log:** every staff change (XP, sheet locks, Boons and Banes, requests, Culminations, retiring characters) is recorded with who did it and why. It's shown only to staff, folded at the bottom of the SOUL tab.

## 2026-10-14: Security rules (owner)

The owner answered the security review (`security/review.md` in the project files). All of these are built:

1. **Uploads:** only logged-in players can upload; the open upload route is closed. Pictures stay image-only and up to 5 MB. Each player can upload at most 20 pictures an hour (icons and gallery). One icon per character, up to 30 gallery pictures per character and 50 across all of one player's characters.
2. **HTTPS:** production forces HTTPS. The certificate comes from Kamal at the first deploy.
3. **Changing email** needs the current password, and the old address is told.
4. **Hidden Chapters** become public only when every player agrees, running or finished.
5. **No editing or removing Passages** once staff lock a Chapter or it's finished.
6. **Scribes' bans are limited:** no ranges wider than /16 (IPv4) or /32 (IPv6), never staff at or above them or the Founder, and they only lift bans from their own level or below.
7. **Posting limits** on the OOC Chat, Passages, Messages, reports, invitations, rolls and new characters. Someone who hits a limit 3 times within 10 minutes is muted for 10 minutes. Staff see "Muted" on Players and staff and can lift it.
8. **Passwords:** at least 10 characters, with a number, a capital letter and a lower-case letter. Existing passwords keep working until they're changed.

## 2026-10-14: Characters are retired, never deleted (owner)

- Characters are never deleted. They are retired (idle) instead, and logs and the Archives still show them, greyed out. This replaces the earlier rule that only the highest admin can delete characters.
- Deleting a player account keeps that player's characters, as archived. Still open: whether the account itself should be archived instead of deleted.
- As built: Wellkeepers retire a character (or bring it back) from Admin → Characters. A retired character can't be played and leaves the Where list, Settings and the character switcher. An account that still has characters can't be deleted, so no character is lost by accident.

## 2026-10-14: Rosters (owner)

The roster is a list of characters other players can apply to take over, with staff approval. Idle characters go back on the roster. The owner picked "Both": the roster, plus a public character directory that includes it. Answers to the task 0016 questions:

1. **Idle:** after a set time without a post or move (a game setting, 90 days by default), when the player gives the character up, or when staff decide.
2. **Players and the roster:** the application has a checkbox, "return this character to the roster if it goes idle". A player can also ask to put a character straight on the roster without waiting for it to go idle; staff review and approve that.
3. **Applying:** the character's existing Application tab answers stay, plus a short note on how the applicant would play it, through the normal staff approval.
4. **What the new player gets:** everything in character, including secrets (private fields, the SOUL sheet and explanations, relationships, gallery). Nothing out of character, such as Messages, and not the old player's unfinished Chapters.
5. **Past Manuscripts** credit neither player.
6. **Staff can add unowned characters** (pre-made or "wanted") to the roster.

## 2026-10-14: Accounts are archived, not deleted (owner)

Player accounts are archived instead of deleted, for now. The Founder can delete an account only if it never had any characters.

## 2026-10-14: Jcink features (owner approved)

From the Jcink shortlist (`design/jcink-shortlist.md` in the project files), all six recommended features are approved:

1. Mini-profile beside every Passage (image and name now; a few game-chosen profile fields added).
2. A "My Chapters" tracker per character: open Chapters, Setting, whose turn, last post.
3. An alerts bell: new post in your Chapter, your turn, @mentions, a Chapter you were in finished.
4. A Chapter subtitle, plus staff-defined labels such as content warnings, shown in the Setting's Chapter list.
5. A character directory players can filter by public profile fields (claims lists build themselves).
6. Game-defined character groups (houses, factions) that colour the character's name.

Awards and profile comments are "maybe later" (Version 2.0). Points and shop aren't adopted.

## 2026-10-14: Step 5 details picked while building (SOUL basics)

Defaults picked by Claude, for the owner to check. The numbers follow the SOUL plugin's defaults.

- **Aspects and Skills** start as the plugin's set: Body (Strength, Speed, Stamina), Mind (Intelligence, Learning, Wit) and Spirit (Ceremonial Magic, Hedgecraft, Natural). Wellkeepers change them under SOUL in the admin panel. The other numbers (points, costs, difficulties) are in `config/soul.yml`, not on a screen yet.
- **Who sees a sheet:** the character's player and staff. Other players only see roll results in Chapters.
- **Starting sheet:** Resonance from -3 to +3. At Resonance 0 a character has 15 Skill points (highest starting Skill 7) and 5 Aspect points; each step of Resonance adds or removes 2 Skill points and 1 from the cap. The sheet locks when staff approve the character. In games without approval, the player presses "Finish my sheet".
- **After locking,** each rating rises one step at a time by spending XP, with the cost shown on the button. Staff can unlock a sheet to fix it; unlocking goes back to the starting-point rules, so XP-bought ratings count against starting points until it's locked again.
- **XP:** 1 a week to every approved character (Sundays at midnight), and 1 to each approved character who posted in a Chapter when it finishes (once per Chapter, even if it's reopened and finished again). Characters behind the median earn up to double on these until they catch up. Staff can give or take XP with a reason, and every change is listed on the sheet.
- **Rolls:** a "Roll a Skill" box under the writing box in a Chapter. Pick a Skill and a difficulty (Standard 13 by default); the game posts the result as a Roll line that anyone can open to see the dice. Rolls don't take a turn, can't be edited or removed, count as activity (so they wake a paused Chapter), and stay in the Manuscript. Rolling happens only inside Chapters.
- **Game setting:** "Use SOUL" is on by default. Turning it off hides sheets, XP and rolls without deleting anything.
- Coming in step 6: Boons and Banes (they change rolls), GM-assisted rolls, Culminations, Narrative History and the staff audit trail.

## 2026-10-14: Step 4 details picked while building (profiles and approval)

Defaults picked by Claude, for the owner to check:

- **Character profile tabs:** Profile (Demographics, the other public fields and the description), Application, Gallery, Relationships and Manuscripts. SOUL, Inklings and Grimoire tabs arrive with those steps.
- **Starting fields:** Birthday, Hometown and Occupation (Demographics, public); Background and Personality (Application, private). Staff add, change, reorder or remove fields under Profile fields in the admin panel, and mark each one public or private and required or not.
- **Private fields** are seen only by the character's player and staff.
- **Game date:** staff set "today's date in the game" and how many game days pass per real day (1 by default). With no date set, the real date is used. Ages come from the birthday and this date.
- **Approval:** off by default. When it's on, a new character starts as a draft and can explore and move around, but can't start, join or post in Chapters until staff approve. Players submit from the character's page once required fields are filled; staff approve or return it with a note, and the player gets an email either way. Characters that already existed count as approved.
- **Drafts and characters waiting for approval** are only visible to their player and staff.
- **Gallery:** up to 30 pictures per character, PNG, JPEG, GIF or WebP, up to 5 MB each, with an optional caption.
- **Relationships:** simple notes. Each one names a character (linked to their profile) or anyone else, picks a kind (Family, Friend, Romance, Ally, Rival, Enemy, Acquaintance, Other) and has an optional note. They're one-sided: each player writes their own.
- **Player profiles:** icon (a pen nib until they upload one; was their initial on a colour before 2026-10-15), player name, staff level, About me, and a "Send a message" button. Their characters are listed only when the game shows who plays which character, though the player and staff always see the list. Reached from the player's name in the header, "My player profile" in the Menu, and names in the OOC Chat. Only logged-in players can see them.

## 2026-10-14: Step 3b details picked while building (Messages)

Defaults picked by Claude, for the owner to check:

- **Addressing:** the To box takes player names or character names, separated by commas, up to 8 people. A character's name reaches whoever plays them.
- **"The player of":** while the game hides players, someone reached through a character's name is shown to the others only as "The player of [character]", on every message they send in that conversation. If one message names two characters played by the same person, they're added once, under the first name.
- **Game setting:** "Everyone can see who plays which character" is off by default, as decided. When it's on, a character's name simply adds their player by name.
- **Reading:** only people in a conversation can open it; staff can't read Messages. Anyone can leave a conversation, and the others still see what they wrote.
- **Alerts:** the header shows "Messages" with a count of conversations that have something new, updated live. New messages are emailed like Chapter activity (one email per conversation until it's read, and in the away-for-days digest), and pop up in the browser for players who chose every Passage or the minutes setting.
- **Limits:** 10 new conversations and 20 replies a minute per player.
- Not built yet: reporting a message to staff, and blocking a player. Both are worth adding before launch.

## 2026-10-14: Ideas taken from the old MUSH logs

Built from the patterns in the owner's old logs, with defaults picked by Claude:

- **Paths in a Chapter:** a Chapter's Setting box lists the Setting's Paths as small buttons when your character is standing there, so you can walk out from a Chapter.
- **My places:** a "Save to My places" button on every Setting, and a My places page in the Menu with Travel buttons. Saved places belong to the player, so all their characters share them. Travel is instant, without the old MUSH delay.
- **Idle times on Where:** "active", "idle 25m", "idle 3h" or "idle 2d" next to each character, counted from the character's last post or move. It isn't the player's login time, so it doesn't link a player's characters together.

## 2026-10-14: Security review fixes

Fixes from the security review (owner asked for them through the project chat). Defaults picked by Claude where the review left a choice:

- **Hidden Chapters:** going public needs every player's agreement, whether the Chapter is finished or still running (the reviewer's recommended default; the owner hasn't confirmed it yet). The agreement buttons are on a running Chapter's settings page. Finished and locked Chapters' settings can't be changed.
- **Passwords** need at least 8 characters.
- **IP bans** can be no wider than /16 (about 65,000 addresses) for IPv4 or /32 for IPv6. They never apply to the Founder or to staff at or above the level of whoever set them, and only staff at that level or above can lift them.
- **Posting limits** per account (or per address for guests): OOC Chat 10 a minute (guests 5), Passages 20 a minute, invitations 20 a minute, reports 5 and new characters 5 per 10 minutes.
- **Changing your email** needs your current password, and the old address gets an email saying it changed.
- Left for the owner at launch: Cloudflare, the firewall, SSH settings, 2FA on the owner's accounts, and the Kamal SSL and upload-size settings.

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
| room | **Place** (was Setting until 2026-10-15) |
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
2. **Deleting characters:** only the highest level of admin can delete a character. Inkwll needs several staff levels. *(Replaced on 2026-10-14: characters are never deleted, only retired. See "Characters are retired, never deleted".)*
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
