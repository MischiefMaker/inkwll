# Changelog

Short, plain-language notes on what changed. Newest first.

## 2026-10-16 — Chapter page and Directory tidy-up

- Each Chapter has a number at the top ("Chapter 12") that never changes, and it stays on the finished Manuscript.
- On wide screens, the Place, who's in the Chapter and Roll a Skill sit in a column beside the story, so the writing box takes less room. The writing box itself is shorter, with "Writing as" and Passage/NPC/Narration/OOC on one line.
- The Place box at the top is smaller, with its Paths on the right.
- Storytellers no longer get a card in the cast at the top of a Chapter.
- The Character Directory opens on an Active tab (approved characters being played), then the groups, with Roster and Unapproved set apart. Each character is a card with a tall picture.

## 2026-10-16 — Lock the Game, profile tabs

- Wellkeepers get a red "Lock the Game" button on the admin page. While locked,
  guests and non-staff players see a page saying the game is locked (they can
  still log in or out); staff keep working and see a banner. "Unlock the Game"
  undoes it.
- Character names are links to their profile, and player names links to theirs,
  in more places: Chapter lists, wiki Manuscript lists, invited lists, the
  who's-online list, forum and wiki "by" lines, pop-ups and admin tables.
- Fixed: clicking an alert in the bell drop-down showed "Content missing"; it now opens the Chapter or Inkling.
- Character profile tabs are now three separate blocks, one under the other:
  Profile, then the private tabs, then Manuscripts and Active Chapters.
- Inklings made from an application's Goals and Secrets are called "Lucia's
  First Goal" and "Lucia's First Secret". Existing ones are renamed on deploy.

## 2026-10-15 — Chapter layouts

- Chapters have a new look, Manuscript: a serif page like a book, with the cast as cards under the title, small round pictures beside each Passage, narration centred, OOC as side notes and a ✦ ✦ ✦ break when half a day or more passes.
- Admin → Look can switch to Forum (a portrait and details beside every Passage) or Chat (the old look), and set Manuscript's cast and Passage pictures to large or small.

## 2026-10-15 — Wells page

- The Founder has a new Admin → Wells page (nobody else sees it). It shows which version the game runs and lists the versions Claude has marked ready, each with what changed. Update to a newer one, or Go back to an earlier one, with one button. GitHub does the work, and the page shows how it's going with a link to the log.
- Every deploy now backs up the database on the droplet first. If the backup fails, nothing changes.
- The page needs a GitHub key before it can update anything; it shows the steps to make one.

## 2026-10-15 — inkwll.com

- The game moves to https://inkwll.com with HTTPS. www.inkwll.com sends
  visitors on to inkwll.com.
- With HTTPS, logins last a year again instead of until the browser closes.

## 2026-10-15 — Menu tidy-ups

- The admin front page has quick-action buttons across the top (New Character, New Place, Player List, Character List, Reports and more, only the ones your job allows) and a Needs Attention list of waiting work below them.
- A character's name, icon and details sit in a box on their profile, at the top or at the side like a wiki infobox. Pick which in Admin → Look. Long answers and pictures stay on the Profile tab.
- Each count at the bottom of the front page has an icon, and its label links to the list: Characters to the Directory, Chapters to Where, Archives to the Archives and Players to a new Players list (icons and names only, never who they play).
- Fix: the OOC Chat is sized from its real position below the header, so it no longer scrolls or leaves a gap at the bottom.
- Character profiles have an Inklings tab, only for their player and staff (staff see only Inklings the player sent them). The tabs are now in three groups on one row that never wraps: Profile, Application, Relationships, Image Gallery | SOUL, Inklings, Grimoire | Manuscripts, Active Chapters.
- On the next deploy, every approved character's Goals answer from their application becomes a Goal Inkling for them (new approvals already did this). The same step makes sure the Goals and Secrets fields start Inklings when a character is approved. It won't make a second one if they have it.
- The old list of links on the admin front page is gone; the buttons and the side menu replace it.
- Fix: the admin side menu keeps one fixed height (the screen below the header) and sticks at the top as you scroll instead of growing; its last link can always be reached by scrolling inside it.
- The front page ends with counts of Players, Characters, Chapters and Archives. Archived players, retired and roster characters, and private or hidden Chapters aren't counted.
- The lowest staff level, "Page", is now called Steward (so "Build Page" and "App Page" become "Build Steward" and "App Steward"). Only the wording changed.
- Wiki pages in the Menu have a small dot before them.
- Small signs show who can see something: a lock (only you and staff), an open eye (only you) and a star (only staff). They're on the restricted profile tabs, private profile fields, private and hidden Chapters, and staff-only notes.
- Email will be sent through Brevo; setup steps are in docs/email-setup.md.
- The wiki page form has Edit and Preview tabs; Preview shows how the page will look without saving.
- Wiki pages added to the Menu are indented so they look nested under Wiki.
- The admin side menu is sized to the screen and stays in place as you scroll, like the OOC Chat.

## 2026-10-15 — Roster section in Admin → Characters

- Admin → Characters is split into Approved and New (not approved yet), then Roster and Retired, and each section can be folded away.
- Roster characters have their own section above Retired. Retiring one takes it
  off the roster (applications for it are dropped); it shows under Retired with
  "Put back on the roster".

## 2026-10-15 — Paths grouped by type

- My Characters shows each character's icon, is split into sections by Group, and shows the quill when it's that character's turn.
- The next deploy puts the starter Boons and Banes back once, if the game has no active ones left (the owner cleared their test entries).
- The SOUL Skill "Natural" is now "Natural Magic".
- Character profiles have an Active Chapters tab for their player and staff, listing the open Chapters they're in (with the quill when it's their turn). Hidden Chapters only show to the players in them.
- Clicking an Area's name on the front page opens its overview page.
- Clicking a twitching quill beside a character, Area or Setting opens the Chapter where it's your turn (the tab and folded-button quills keep their own click).
- The twitching quill also shows beside the front page's "[Character] is in [Place]" line, and beside any Area or Setting where it's your turn.
- The front page header takes up less space (less padding above, around and below the name and blurb).
- A Chapter tab shows the same twitching quill when it's your turn, top right above "Your turn".
- Staff and Storytellers can pick GM in the Writing as switcher too (it warns first if GM isn't in the Chapter yet).
- Games can have their own icon (Admin → Game settings): small beside the name at the top left, larger in the front page header. The default is the favicon's inkwell.
- A Birthday profile field can show just the age ("Age: 27") beside Passages, with its own tick box in Admin → Profile fields.
- Playing as is a menu showing each character's icon and Group colour.
- The front page's "[Character] is in [Place]" line has a very small icon beside the name, in the Group colour.
- The Chapters button is the same size as a tab while open, and folds down to a small "+ (3)".
- A Place's Paths are broken out under headings: Streets first, then Buildings,
  Outdoor areas and Other places (by the type of Place each leads to).

## 2026-10-15 — Locked fields, Place types, tabs and more

- Profile fields have a "Player can edit after approval" tick box. Untick it
  (Background starts unticked) and a player can't change that answer once
  their character is approved; they see it greyed out. Staff always can.
- Place types are now: Nothing special, Building (with separate units),
  Building (no units), Street and Outdoor area (park, square...). Hotels,
  dormitories and office blocks became buildings with separate units. Their
  numbered list is called "Units".
- Menu entries use Title Case, and "My player profile" is now "My Profile".
- The front page's column of Area and Board cards is centred beside the OOC Chat (text stays left-aligned).
- Chapter tabs can fold away (remembered in your browser). While folded, a
  wiggling quill shows when it's your turn somewhere. A finished Chapter's tab
  has an X to close it for good. The OOC Chat shrinks to fit under the tabs so
  its box is always visible.
- All Places is grouped by Area.
- Writing a Passage: a "Writing as" switcher, which warns before it brings a
  character who isn't in the Chapter into it.
- Admin → Characters lists retired characters in their own section.
- Putting a character you're playing on the roster moves you to your next
  character instead of leaving "Playing as" blank.
- Roster characters who've been played before say so.
- After chatting as a guest and logging in, the OOC Chat box no longer still says you're chatting as the guest.

## 2026-10-15 — Starter SOUL, Boons and Banes, and profile fields

- A new game comes with SOUL's Aspects and Skills from the SOUL plugin
  (Body, Mind and Spirit, three Skills each), a starter catalogue of six
  Boons and six Banes, and a few profile and Application fields. Games that
  already set these up keep their own.
- Staff can delete a Boon or Bane from Admin → Boons and Banes with the new
  trashcan button. One that characters already have is retired instead.
  Edit is now a pencil button.
- Character descriptions are now an ordinary profile field called
  Description, which games can rename, remove or make required. Existing
  descriptions were copied into it.
- Staff and Storytellers can pick **GM** under Playing as, to post and run
  Chapters under their player name. A Chapter they start as GM makes them its
  Storyteller. GM isn't a character: it never shows in Where, Here, the
  directory or character lists.
- Settings (rooms) are now called **Places** everywhere players see them,
  so they aren't confused with account settings. The wiki's
  `{{settings}}` list is now `{{places}}` (the old spelling still works).
- A profile field can start an Inkling: when staff approve a character, its
  Goals answer becomes a Goal Inkling and its Secrets answer a Secret one
  (set per field in Admin → Profile fields). Staff don't see them until the
  player sends them. Games get a starter Secrets field.
- Staff see what's waiting on them in the bell: its number includes
  applications, roster requests, SOUL requests, Inklings sent to staff,
  spell proposals and reports (whichever their jobs allow), and the drop-down
  lists each with a count and a link. The number updates live.
- When staff review an application they can now open the SOUL sheet, Grimoire,
  gallery and relationships in tabs, not just the profile answers.
- Switching to GM, or from GM back to a character, keeps you on the page you
  are on instead of taking you to your character's place.
- The SOUL sheet has an "i" icon, "What do the ratings mean?", opening a
  pop-up that says what's ordinary and what's superhuman. Staff write the
  ranges in Admin → SOUL (new games start with six: Untrained to
  Superhuman). It's explanation only and changes no rolls.
- Edit and Delete (and Remove) links across the site are now the pencil and
  trashcan icons: Passages, Boards, the wiki, profile and SOUL screens, and
  the admin lists.
- Online now on the front page is a heading with a count, "Online now (3)",
  with a separate "See where everyone is" link. Players show as small cards
  with their icon and name, and the character they're playing in its group
  colour (only if the game shows players publicly, or to staff).
- The Character directory has tabs: All, one per character group, Roster,
  and (for staff) Unapproved.
- The Menu is grouped into sections: Mine, The world, Community and help,
  and Staff.
- The Inklings page always shows Start an Inkling, and says why it can't be
  used yet when none of your characters is approved.
- The alerts bell opens a small drop-down over the page instead of a new
  page.
- Online now on the front page lists players by player name; Where lists
  characters.
- Profile fields can ask for a Picture, for games that show looks with an
  image instead of text.

## 2026-10-15 — Preparing roster characters

- A character staff add to the roster from Admin → Roster is no longer shown
  as retired. Adding one takes staff to its profile to fill in, and players
  can't see it until staff press "Open on the roster".
- Staff who review applications can edit roster characters (Edit on the
  profile and in Admin → Roster), including their SOUL sheet and gallery.

## 2026-10-15 — The Prologue

- New characters start in The Prologue, an out-of-character reading room
  (in an "Out of Character" Area), instead of an in-character Setting. Its
  Paths lead into each Area. Existing games get it on their next update;
  characters already playing stay where they are.

## 2026-10-15 — More for guests to read

- Guests (not logged in) can now read the Boards, the Wiki, Where, the
  character directory and Roster, character and player profiles, the
  Archives and any Chapter a player could watch. They can't post, edit or
  join anything. Their top bar has a Menu with all of these, and the front
  page shows the Boards.

## 2026-10-15 — Icons

- The top bar and the Menu have small line icons next to each link.
- Areas, Settings and boards without an icon picture show a drawn one
  instead (a compass, a door, a speech bubble), in the look's colours.
- Areas and Settings without a banner picture show a plain drawn banner.
- Players without an icon picture get a pen-nib icon instead of their
  initial; guests get a grey one.
- New favicon: a slate inkwell and quill on a gold circle.
- On phones the top bar is two short rows: the game's name and your account,
  then the links as icons only.

## 2026-10-15 — Area banners on Settings

- A Setting now shows its Area's banner and short text above its own name,
  when the Area has them, so you can see where you've arrived.

## 2026-10-15 — OOC Chat moderation

- Players can edit and delete their own OOC Chat messages. Staff can edit
  and remove anyone's. Edited messages say "(edited)" (or "(edited by
  staff)"), and deleted ones stay in place as "Deleted" or "Removed by
  staff".
- Staff who can ban can block someone (a player, or a guest's address)
  from posting in the OOC Chat only, for a set time or for good, with
  Block on one of their messages. They can still log in and play.

## 2026-10-15 — Testing tweaks

- Headings use a plain sans-serif font in the default Slate blue and gold
  look, instead of Georgia/Times.
- The log in, sign up and OOC Chat pages keep the top bar for visitors, so
  they can get back to the front page. Visitors also see the OOC Chat
  beside every page (when the game allows guest chat), and the log in and
  sign up pages invite them to say hello there.
- On phones the OOC Chat drops down from a bar marked "OOC Chat" instead
  of folding out from the side.

## 2026-10-14 — Logging in on the live game

- Fixed signing up and logging in on the live game while it runs on plain
  http. Until it has HTTPS, a login lasts until the browser is closed.

## 2026-10-14 — Audit follow-ups

- Retired characters and characters on the roster no longer get weekly XP.
- A Private Chapter can't be opened up by one player alone. Like a Hidden
  one, it becomes public once every player agrees.
- Renaming a wiki page no longer breaks links to it: old addresses
  redirect to the new one.
- One failed digest email no longer stops everyone else's.

## 2026-10-14 — Long Chapters stay quick

- An open Chapter shows its latest 50 posts, live. "Read the whole
  chapter" above them opens every post on a page that doesn't update by
  itself. Finished Chapters still show everything.

## 2026-10-14 — Bug fixes from the code audit

- A password reset link with the new password left blank no longer says
  "Password changed" (it changed nothing) and logs the player out.
- A ban with an end date that doesn't exist (31 February) shows an error
  instead of an error page.
- "@Wrenna" no longer also alerts the player of Wren: a mention has to
  match the whole name.
- Archived players no longer get activity or digest emails.
- The numbered-rooms tool points out a line that doesn't start with a
  door number instead of showing an error page.
- Retiring a character (or archiving its player) takes it out of its
  unfinished Chapters, so turns don't wait on someone who can't post.
- The last character leaving a Chapter on their own turn is no longer
  told it's their turn.
- Nobody can be invited into a finished Chapter, so one player can't let
  others read a Hidden Chapter without everyone agreeing.
- Rolls can't be removed or edited, even by a hand-made request.
- Messages can't be sent to the roster or to archived players, where
  nobody would read them.

## 2026-10-14 — Getting started guides

- A players' "Getting started" page gives new players their first five
  steps, then explains Areas, Settings, Paths, Chapters, Passages, the
  Archives and Messages. It's first in the Menu, and guests see it in the
  top bar before they sign up.
- A staff "Getting started" page in the admin panel walks through setting
  up a new game in order, and where the day-to-day jobs are. Only staff
  can see it.

## 2026-10-14 — Optional email and staff reset links

- Games that make email optional (Game settings) now have a way back in
  for players without one: staff open the player in Players and staff and
  make a password reset link to send them. It works for a day.
- The sign-up and new-password pages now give the real password rule
  (10 characters, with a number, a capital and a lower-case letter).

## 2026-10-14 — Guests can preview

- Visitors who aren't logged in can look around: the front page shows
  Preview instead of Enter, and they can open Areas and Settings and follow
  the Paths. Log in and Sign up are at the top.
- A Setting's "Here" list shows guests looking at it: "Guest", or
  "3 Guests".

## 2026-10-14 — Enter and default Settings

- Every Area on the front page has an Enter button, which moves your
  character to the Area's default Setting. Areas with no Settings show Look.
- Builders tick "Default Setting for its Area" on a Setting's edit page.
  Without one, Enter goes to the first Setting made in the Area.

## 2026-10-14 — Path types

- Paths have a type: Street, Building or Unit. Streets can point a compass
  direction; buildings are listed under "Go in" on a Setting; units are the
  numbered doors (apartments and the like).
- A new direction, Out: the way back from a building or unit. "Add the
  way back" makes it for you, and on the compass it sits in the middle.

## 2026-10-14 — Apartment-style Settings

- A Setting can be a special type: apartment building, hotel or inn,
  dormitory, office block or street of houses (Edit setting, "Type of setting").
- Paths can have a number. Numbered Paths show as a compact list in columns,
  "100 - Jaxon Marley", with a search box once there are more than 12.
- "Add numbered settings" on a Setting's edit page makes many at once from
  lines like "100 Jaxon Marley", each with a Path in and a Path back out.
- Rooms behind numbered doors stay out of Area lists and Shortcuts.

## 2026-10-14 — Path directions and a compass

- Paths can have a compass direction, from N round to NNW (16 points).
  Leave the name empty and the Path is named after its direction; tick
  "Add the way back" and the return Path points the opposite way.
- Paths are listed clockwise from north, with their direction beside them.
- Admin, Features has a new Compass switch: each Setting then shows a
  compass rose with its Paths at their points, clickable to walk.

## 2026-10-14 — Old-school MUSH look

- A new ready-made look in Admin, Look: "Old-school MUSH". White Courier
  text on black, with ANSI colours for context: names in yellow, Paths in
  green, OOC in magenta, links and buttons in cyan.

## 2026-10-14 — Forum boards

- New forum-style Boards for things that work better than a Chapter:
  news, advertising, wanted ads and so on. They're listed on the front
  page after the Areas, as cards like the Area cards, and in the Menu.
- Each board has threads and replies, written in Markdown and posted under
  the player's name. Writers can edit their own posts; Scribes and
  Wellkeepers can pin, lock and delete threads and delete replies.
- Admin, Boards (Scribes and Wellkeepers) adds, renames, reorders and
  removes boards, with a small icon and banner, and picks who can start
  threads and who can reply on each: anyone with an account, staff only,
  Scribes and Wellkeepers only, or (for replies) nobody.
- New games start with three boards: News (staff start threads, anyone
  replies), Advertising and Wanted ads (anyone).

## 2026-10-14 — Simpler look and the game's name

- The front page now opens with the game's name in large letters and a
  paragraph or two about the game. Set both in Admin, Game settings. The
  name also replaces "Inkwll" in the top bar and the browser tab.
- The front page lists just the top-level Areas, each with an Enter button
  that takes your character to the Area's entrance (or Return, if you're
  already there). Shortcuts to single Settings are tucked into a small
  "Shortcuts" fold.
- Areas and Settings can each have a small icon, a large banner, a page
  background, short text and long text. All optional.
- Admin, Look takes background pictures for the whole page, for boxes and
  panels, and for behind the game's name.
- On a Setting's page, its Paths and who's here now sit in one box right
  under the description, above the Chapters. "Travel here" stays for
  Settings you look at from afar (owner's choice).

## 2026-10-14 — Admin menu

- The admin panel's row of tabs is now a menu down the right-hand side,
  grouped under headings (Waiting on staff, Game world, Players and
  characters, Moderation, Game systems, Settings), like Jcink's admin CP.
  On a phone it folds into one "Admin menu" button at the top.
- The OOC Chat folds away when you go into the admin panel and comes
  back as you left it when you go back to the game.

## 2026-10-14 — Build several Settings at once

- Building has a new "Build several settings" screen: add as many Settings
  as you like with "Add another setting", then link them with Paths (one
  way or both ways) to each other or to existing Settings, and save it all
  in one go. If anything is wrong, nothing is saved and the form keeps
  what you typed.

## 2026-10-14 — New starting map

- A fresh game now starts with three Areas, City, Country and Forest,
  each holding three smaller Areas (Uptown, Midtown and Downtown; The
  Village, Farmland and Riverside; Forest's Edge, Deep Woods and
  Lakeshore). Each small Area has two described Settings, all joined by
  Paths, and the three big Areas link to each other. New characters
  start in Central Square. Everything can be edited or replaced from
  the admin panel.

## 2026-10-14 — Storyteller tools

- A Chapter's Storyteller can call for rolls from players, see the
  players' Aspects and Skills, and suggest XP that staff approve.

## 2026-10-14 — Default look

- New games start in Slate blue and gold, and the admin panel asks the
  admin to pick a look (plain and the others are one click away).

## 2026-10-14 — Roster options

- Games choose how roster characters change hands: claim and play
  straight away, answer some questions again, or redo the whole
  application.
- Fixed: changing a profile answer that was already filled in didn't save.

## 2026-10-14 — Step 10: Platform

- Admin → Features: switch SOUL, Inklings, Grimoire, the wiki and guest
  chat on or off in one place.
- Admin → Look: pick the game's colours (light and dark), fonts and extra
  CSS, or start from one of three ready-made looks.

## 2026-10-14 — Step 9b: Wiki

- A wiki in the Menu for rules, lore and plots. Anyone with an account can
  write pages in Markdown, link them with [[Page name]], and pull in live
  lists of characters, Manuscripts, Settings and pages. Every change is
  kept, staff can lock pages, and staff can list pages in the Menu.

## 2026-10-14 — Step 9: Grimoire

- Magic, for games that switch it on: branches tied to SOUL Skills, spells
  learned with XP and cast in Chapters as rolls, and spell proposals that
  staff approve.

## 2026-10-14 — Step 8: Inklings

- Inklings: threads about a character (goals, secrets, requests, hints)
  that players build up, share and send to staff. Staff approve them, ask
  for changes, add staff notes and grant rewards through SOUL.

## 2026-10-14 — Step 7: Game time

- Each Chapter has its own in-character date and time of day, which its
  players can move forward. The Chapter notes each change.
- The front page shows the game's date, today's weather and who's online.

## 2026-10-14 — Step 6c: Ideas from Jcink boards

- An alerts bell in the header for new Passages, your turn, @mentions and
  finished Chapters.
- "My Chapters" in the Menu lists each character's open Chapters, whose
  turn it is and who posted last.
- Chapters can have a subtitle and labels such as content warnings.
- Character groups (houses, factions) colour their characters' names, and
  games can show chosen profile fields beside Passages.

## 2026-10-14 — Step 6b: Rosters

- A roster of characters other players can apply to take over. Staff pick
  who gets each one, and the new player gets everything in character.
- Players can tick "put on the roster if they go idle", or ask staff to put
  a character on the roster now. Staff can also add new characters to it.
- A character directory in the Menu lists everyone being played and the
  roster, and can be filtered by public profile fields.
- Accounts are archived instead of deleted. A Founder can delete an account
  that never had characters.

## 2026-10-14 — Step 6: SOUL extras

- Boons and Banes: staff keep a catalogue, players pick theirs on a starting
  sheet or ask staff later, and they change rolls of the Skills they're tied to.
- Players can ask a Chapter's Storyteller to judge a roll.
- Culminations: players propose milestones and staff approve them.
- Each character has a Narrative History, and staff have a log of every
  staff change.

## 2026-10-14 — Security rules

- New passwords need 10 characters, with a number, a capital and a
  lower-case letter.
- Picture uploads are limited to 20 an hour, and 50 gallery pictures across
  all of one player's characters.
- Anyone who keeps hitting the posting limits is muted for 10 minutes. Staff
  can lift it from Players and staff.

## 2026-10-14 — Retiring characters and faster cloud sessions

- Characters are no longer deleted. Wellkeepers retire them instead, and
  their Passages and Manuscripts stay, greyed out.
- New cloud sessions now start the database, install gems and set up the
  databases automatically.

## 2026-10-14 — Step 5: SOUL basics

- Characters have a SOUL tab: Resonance, Aspects and Skills. Players set a
  starting sheet with points, and it locks at approval.
- XP arrives every week and from finished Chapters. Players spend it to
  raise ratings, and staff can give or take XP.
- A "Roll a Skill" box in Chapters rolls 2d20 plus the Skill and posts the
  result for everyone.
- Wellkeepers set the game's Aspects and Skills under SOUL in the admin panel.

## 2026-10-14 — Step 4: Profiles and approval

- Character profiles have tabs: Profile, Application, Gallery, Relationships
  and Manuscripts. Staff choose the profile questions and whether each is
  public or private.
- Ages are worked out from a character's birthday and the game's own date,
  which staff set in Game settings.
- Games can require staff approval. New characters are drafts until a
  player submits them and staff approve; until then they can explore but
  not join Chapters.
- Players have their own profile with an icon and About me.

## 2026-10-14 — Step 3: Logs and safety

- Players can finish a Chapter (and undo it for a day). Idle Chapters are
  finished by the game after a month.
- Finished Chapters go into the Archives as Manuscripts, which you can filter
  by Setting or character. Hidden ones need everyone's agreement first.
- Players can report a Passage or Chapter. Staff can then read it, hide a
  Passage, lock the Chapter, warn the player, or ban an account or address.
  Games can block known VPNs.
- A new Notifications page lets players pick activity emails (with the missed
  Passages included) and browser pop-ups. Every email has a "stop these
  emails" link.
- "Forgot your password?" on the log-in page emails a reset link.
- Chapters have OOC lines, narration and NPC Passages as well as ordinary
  Passages. OOC lines don't take a turn and stay out of the Manuscript.
- Messages: out-of-character conversations between players, one-to-one or in
  groups. Message a character's player without learning who they are. New
  messages show in the header, by email and as browser pop-ups.
- A Chapter's Setting box shows the Paths out. Settings can be saved to My
  places for one-click travel, and the Where list shows idle times.
- Security fixes: switched off an upload address that could fill the disk,
  forced HTTPS on the live site, required your password to change your email,
  made hidden Chapters need everyone's agreement to go public, blocked edits
  after a Chapter is finished or locked, limited how wide IP bans can be (and
  kept them off senior staff), added posting speed limits, and set an
  8-character minimum for passwords.
- Every part of every page has a CSS class for skins, listed in
  `docs/css-classes.md`.
- Players can pause a Chapter, with a note saying when they'll be back.
- Guests can chat in the OOC Chat without logging in, with spam protection.
- Arial is now the default font, in emails too.
- The OOC Chat has its new name, a coloured header bar and a tiny icon by
  each player. Chapters and the Where list show each Setting's Area names.

## 2026-10-14 — Step 2: Chapters

- Characters can start Chapters in the Setting they're standing in, and join
  or leave them. Chapters can be Open, Private (invite only) or Hidden.
- Passages appear live, with the character's icon and name. Clicking either
  opens a small profile. You can edit or remove your own Passages.
- Turns: take turns, free-for-all, or the 3-Passage rule. Pass your turn,
  storytellers can skip someone, and players who go quiet get a warning and
  are skipped after a few minutes unless they click "I'm here!".
- Characters can upload an icon.
- Your Chapters show as tabs on every page, with unread counts. The browser
  tab shows a count and the site icon gets a dot when something's new.
- Moving between Settings adds arrival and departure lines to Chapters there.
- A Where page (in the Menu) shows where everyone is. Front-page boards show
  their latest open Chapter.

## 2026-10-14 — Step 1b: Step 1 changes

- Players now see themed words: Setting (room), Path (exit), Area, and later
  Chapter, Passage, Manuscript and Archives. They all live in one file,
  `config/locales/en.yml`.
- The front page lists the game's Areas like forum boards. Areas can sit
  inside other Areas, and each Setting belongs to one.
- Areas and Settings can have an image, a description, or both.
- Extras (all Settings, OOC chat, admin panel) moved into a Menu.
- The OOC chat can fold into the right edge and slide back out. Each browser
  remembers whether you left it open.
- While the OOC chat is folded, its tab shows how many new messages you
  haven't seen.
- Sign-up has a box to opt in to email notifications. The emails themselves
  arrive in step 3; the choice is saved now.
- One player name for logging in and for the OOC chat. Accounts now have an
  email address, required unless the game turns that off.
- Character names can use spaces and special characters.
- Building a Path can add the return Path at the same time.
- A game with no Settings gets a default starting Setting.
- The front page shows each top-level Area as a banner, with the Areas inside
  it as boards. Opening a board takes you to its entrance Setting, and an
  arrow beside its name lists shortcuts inside.
- "Travel here" moves your character straight to a Setting you're looking at.
- The admin panel has its own tabs.
- Staff levels (Page, Scribe, Wellkeeper), the Founder flag, Page jobs and the
  Storyteller flag, set from a new admin panel. Wellkeepers can delete
  characters and change game settings.

## 2026-10-14 — Project tracking

- Added a decisions log, roadmap, task board and a guide for handing small
  tasks to other AIs (`AGENTS.md`, `docs/`, `tasks/`).
- Added the settled answers on SOUL, Inklings, Grimoire, hidden-scene access
  and hosting to `docs/design.md`.
- Fixed the automatic system-test check, which failed because the
  `test/system` folder was missing.

## 2026-10-14 — Step 1: Foundation

- Created the Rails 8.1 app (Hotwire + PostgreSQL). Stack confirmed by the owner.
- Moved the planning handoff into `docs/design.md`.
- Accounts: sign up and log in with a username and password. Each account also
  has a player name shown in OOC chat.
- Characters: create and edit characters; a "Playing as" dropdown in the header
  switches the active character.
- The game remembers which character you last used in each room and switches
  back to it when you return.
- Rooms and exits: click an exit to move your active character. The list of who
  is in a room updates live.
- Site-wide OOC chat in a side panel (and on its own page), updating live.
- Staff building tools: create/edit rooms and add/remove exits.
- Placeholder rooms in `db/seeds.rb`.
