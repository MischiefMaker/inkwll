# CSS classes for skins

Every part of every page has a CSS class, so a game can restyle anything without touching the code. This is a guide to the main ones. To see the class of anything on a page, right-click it and choose **Inspect**.

## How the names work

- **Blocks and parts:** `.pose` is a block, `.pose__name` is a part of it, and `.pose--ooc` is a kind of it. So `.pose--narration .pose__body` means "the text of a narration post".
- **Colours, fonts and spacing** are CSS variables at the top of `app/assets/stylesheets/application.css` (`--font-body`, `--color-accent` and so on). Changing those restyles the whole site at once.
- **Every page** puts classes on `<body>`: `page-scenes` (any Chapter page), `page-scenes-show` (just the Chapter itself), `page-admin-bans`, and so on. They are made from the page's address in the code, `page-<section>-<action>`. Add `is-logged-in` or `is-guest`, plus `is-staff` for staff. Use them to style one page only, for example `.page-home-show .page-title`.
- Class names use plain words (`scene`, `pose`, `room`) rather than the themed words players see (Chapter, Passage, Setting), so they stay the same if a game renames things.

## Shared pieces

| Class | What it is |
| --- | --- |
| `.page-title` | The big heading at the top of a page |
| `.section-title`, `.subsection-title` | Smaller headings |
| `.text` | An ordinary paragraph |
| `.muted` | Quieter grey text |
| `.hint` | The small help text under a form field |
| `.emphasis` | Bold or italic words inside text |
| `.list`, `.list__item` | Lists |
| `.table`, `.table__head`, `.table__body`, `.table__row`, `.table__heading`, `.table__cell` | Tables |
| `.disclosure`, `.disclosure__summary` | Fold-out sections ("About this setting") |
| `.form`, `.field`, `.field--checkbox`, `.fieldset`, `.fieldset__legend` | Forms |
| `.button`, `.button--quiet`, `.button-link` | Buttons |
| `.badge`, `.tag` | Small labels ("Open", "Turn") |
| `.flash`, `.flash--notice`, `.flash--alert` | Messages after an action ("Saved.") |
| `.notice-box` | Boxed notices ("Paused since…", "Finished…") |
| `.breadcrumbs` | The Area names above a Setting |

## The frame

| Class | What it is |
| --- | --- |
| `.site-header`, `.site-header__nav`, `.site-header__account`, `.site-header__player` | The bar along the top |
| `.menu`, `.menu__items` | The Menu |
| `.switcher` | "Playing as" character picker |
| `.chapter-tabs`, `.chapter-tab`, `.chapter-tab--current`, `.chapter-tab__title`, `.chapter-tab__setting`, `.chapter-tab__turn`, `.chapter-tab__unread` | Your Chapter tabs |
| `.layout`, `.main` | The page body and its main column |
| `.ooc-sidebar`, `.ooc-sidebar__title`, `.ooc-sidebar__toggle`, `.ooc-sidebar__count`, `.ooc-sidebar--collapsed` | The OOC Chat sidebar |
| `.ooc-message`, `.ooc-message__author`, `.ooc-message__author--guest`, `.ooc-message__time`, `.ooc-message__body`, `.player-icon`, `.player-icon--guest` | OOC Chat messages |

## Front page, Areas and Settings

| Class | What it is |
| --- | --- |
| `.boards`, `.board`, `.board__header`, `.board__title`, `.board__description`, `.board__rows` | The front page's Area boards |
| `.board-row`, `.board-row__image`, `.board-row__title`, `.board-row__description`, `.board-row__activity` | One Setting or Area on a board |
| `.room`, `.description-image` | A Setting's page and its picture |
| `.exits`, `.exit-link`, `.room-paths` | A Setting's Paths |
| `.room-here`, `.where-now` | Who is standing here |
| `.where-room`, `.where-room__areas`, `.where-room__list` | The Where list |

## Chapters

| Class | What it is |
| --- | --- |
| `.scene`, `.scene__header`, `.scene__meta` | A Chapter page |
| `.scene-setting`, `.scene-setting__name`, `.scene-setting__description`, `.scene-setting__here` | The Setting box at the top |
| `.scene-people`, `.scene-people__list`, `.scene-people__actions` | Who's in it, and Leave / Pause / Finish |
| `.turn-bar`, `.turn-bar__text`, `.turn-bar__timer`, `.turn-bar__warning` | Whose turn it is |
| `.passages` | All the posts |
| `.pose`, `.pose__icon`, `.pose__name`, `.pose__time`, `.pose__body`, `.pose__actions` | One post |
| `.pose--passage`, `.pose--npc`, `.pose--narration`, `.pose--ooc`, `.pose--system` | Each kind of post |
| `.pose__tag`, `.pose__played-by` | The OOC / Narration tag, and "NPC, played by" |
| `.composer`, `.composer__kinds`, `.composer__npc`, `.composer__warning` | The writing box |
| `.mini-profile` | The pop-up when you click a character |
| `.scene-list`, `.scene-list__title`, `.scene-list__meta` | A Setting's list of Chapters |
| `.manuscript`, `.manuscript__title`, `.manuscript__meta` | A finished Chapter in the Archives |
| `.character-icon`, `.character-icon--tiny`, `--small`, `--large`, `--initial`, `--npc` | Character icons |
