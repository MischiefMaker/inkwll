# CSS classes for skins

Every part of every page has a CSS class, so a game can restyle anything without touching the code. This is a guide to the main ones. To see the class of anything on a page, right-click it and choose **Inspect**.

## How the names work

- **Blocks and parts:** `.pose` is a block, `.pose__name` is a part of it, and `.pose--ooc` is a kind of it. So `.pose--narration .pose__body` means "the text of a narration post".
- **Colours, fonts and spacing** are CSS variables at the top of `app/assets/stylesheets/application.css` (`--font-body`, `--font-heading`, `--color-accent` and so on; Admin → Look sets most of them). Changing those restyles the whole site at once.
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

## Messages

| Class | What it is |
| --- | --- |
| `.message-count`, `.message-count__number` | The Messages link in the header and its count |
| `.conversations`, `.conversations__item`, `.conversations__item--unread`, `.conversations__subject`, `.conversations__meta` | The list of conversations |
| `.conversation`, `.conversation__members`, `.conversation__messages`, `.conversation__reply` | One conversation |
| `.conversation-message`, `.conversation-message--mine`, `.conversation-message__sender`, `.conversation-message__time`, `.conversation-message__body` | One message |

## Profiles

| Class | What it is |
| --- | --- |
| `.character-profile`, `.character-profile__header`, `.character-profile__name`, `.character-profile__panel` | A character's profile page |
| `.profile-tabs`, `.profile-tabs__tab`, `.profile-tabs__tab--current` | The tabs on a character's profile |
| `.profile-fields`, `.profile-fields__row`, `.profile-fields__private`, `.details-list__term`, `.details-list__value` | Profile answers, such as Demographics |
| `.application-status`, `.application-status--draft`, `--submitted`, `--returned` | The approval notice on a character |
| `.gallery`, `.gallery__item`, `.gallery__image`, `.gallery__caption` | The picture gallery |
| `.relationships`, `.relationships__item`, `.relationships__name`, `.relationships__kind`, `.relationships__note` | Relationships |
| `.player-profile`, `.player-profile__header`, `.player-profile__about`, `.player-characters` | A player's profile |
| `.player-icon`, `.player-icon--tiny`, `--large`, `--image`, `--guest` | Player icons |
| `.character-profile--on-roster`, `.roster-status`, `.roster-status--on-roster`, `--requested`, `.roster-status__note`, `.roster-status__apply` | Roster notices on a character |
| `.roster-apply`, `.roster-apply__form`, `.roster-apply__question`, `.roster-apply__resubmit` | Applying for (or claiming) a roster character |
| `.directory`, `.directory__filter`, `.directory__list`, `.directory__item`, `.directory__item--roster`, `.directory__name`, `.directory__tag` | The character directory and the Roster page |
| `.roster-admin`, `.roster-admin__item--application`, `--request`, `--character`, `.roster-admin__actions`, `.roster-admin__answers`, `.roster-admin__question`, `.roster-admin__answer` | Admin: the Roster page |
| `.character-form__roster` | "If you stop playing" on the character form |
| `.table__row--archived`, `.account-archived`, `.account-actions` | Archived accounts in Players and staff |
| `.character-name`, `.character-name--grouped`, `.character-group-<id>` | A character's name; grouped names take the group's colour from `--group-colour` |
| `.pose__details`, `.mini-profile__details`, `.character-profile__group`, `.directory__group` | The group and chosen fields beside Passages and on profiles |
| `.alert-bell`, `.alert-bell--unread`, `.alert-bell__number`, `.alerts`, `.alerts__item`, `.alerts__item--passage`, `--turn`, `--mention`, `--finished`, `--unread` | The alerts bell and the alerts list |
| `.chapter-tracker`, `.chapter-tracker__character`, `.chapter-tracker__row`, `.chapter-tracker__row--my-turn`, `.chapter-tracker__subtitle` | My Chapters |
| `.inklings`, `.inklings__item`, `.inklings__item--unread`, `--draft`, `--submitted`, `--approved`, `--needs_changes`, `.inklings__type`, `.inklings__type--<type>` | The Inklings list |
| `.inkling`, `.inkling--submitted` (and the other states), `.inkling__status`, `.inkling__review`, `.inkling__write`, `.inkling__sharing`, `.inkling__rewards` | One Inkling |
| `.inkling-entry`, `.inkling-entry--public`, `--private`, `--personal`, `--gm`, `--roll`, `--reward`, `--system`, `--new`, `.inkling-entry__ref` | Entries in an Inkling |
| `.grimoire`, `.grimoire__branch`, `.grimoire-spell`, `.grimoire-spell--known`, `--out-of-reach`, `.grimoire__propose`, `.grimoire-proposal--pending` (and the other statuses) | The Grimoire tab on a character |
| `.cast-box`, `.cast-box__form` | "Cast a spell" in a Chapter |
| `.grimoire-admin`, `.grimoire-admin__branch`, `.grimoire-admin__proposal` | Admin: Grimoire |
| `.wiki`, `.wiki__search`, `.wiki__tags`, `.wiki__tag`, `.wiki__tag--current`, `.wiki__list`, `.wiki__item`, `.wiki__title` | The wiki's list of pages |
| `.wiki-page`, `.wiki-page__title`, `.wiki-page__actions`, `.wiki-page__footer`, `.wiki-page--missing`, `.wiki-page--revision` | One wiki page |
| `.wiki-body` | The written part of a wiki page (style `.wiki-body h2` and so on) |
| `.wiki-embed`, `.wiki-embed--characters` (and the other list names), `.wiki-embed--unknown` | A live list inside a page |
| `.wiki-characters`, `.wiki-character`, `.wiki-manuscripts`, `.wiki-settings`, `.wiki-pages-list` (each with `__item` and `__name` or `__title`) | The lists themselves |
| `.wiki-form`, `.wiki-form__body`, `.wiki-form__help` | Writing a page |
| `.wiki-history`, `.wiki-history__item`, `.wiki-history__current` | A page's history |
| `.menu__wiki-page` | A wiki page listed in the Menu |
| `.features`, `.features__item` | Admin: Features |
| `.admin-setup`, `.admin-setup__look` | "Pick your game's look" on the admin Overview |
| `.skin-presets`, `.skin-preset`, `.skin-preset__swatch`, `.skin-preset__current`, `.skin-form`, `.skin-form__row`, `.skin-form__colour`, `.skin-form__css` | Admin: Look |
| `.inklings-admin`, `.inklings-admin--waiting` | Admin: Inklings |
| `.game-time`, `.game-time__date`, `.game-time__weather`, `.online-now`, `.online-now__list` | The game's date, weather and who's online, on the front page |
| `.scene__when`, `.scene-list__when`, `.manuscript__when`, `.chapter-tracker__when`, `.scene-form__when` | A Chapter's in-character date and time |
| `.scene-list__subtitle`, `.scene__subtitle`, `.scene-labels`, `.scene-label`, `.scene-label--<id>`, `.scene-form__labels` | Chapter subtitles and labels |

## SOUL

| Class | What it is |
| --- | --- |
| `.soul-sheet`, `.soul-sheet--open`, `.soul-sheet--locked` | The SOUL tab on a character |
| `.soul-sheet__points`, `.soul-aspect`, `.soul-trait`, `.soul-trait--aspect`, `.soul-trait--skill`, `.soul-trait__input` | Setting the starting sheet |
| `.soul-sheet__table`, `.soul-trait__rating`, `.soul-trait__bonus`, `.soul-trait__raise` | The locked sheet |
| `.soul-xp`, `.soul-xp__summary`, `.soul-xp__ledger`, `.soul-xp__entry--award`, `--spend`, `--correction` | XP |
| `.roll-box`, `.roll-box__form`, `.roll-box__ask` | "Roll a Skill" in a Chapter |
| `.pending-rolls`, `.pending-roll`, `.pending-roll__form`, `.pending-roll__bnbs` | Rolls waiting for the Storyteller |
| `.soul-bnbs`, `.soul-bnb`, `.soul-bnb--boon`, `--bane`, `--resolved`, `.soul-bnb__name`, `.soul-bnb__kind`, `.soul-bnb__explanation` | Boons and Banes on the sheet |
| `.soul-culminations`, `.soul-culmination`, `.soul-culmination--approved` (and the other statuses) | Culminations |
| `.soul-history`, `.soul-history__item` | Narrative History |
| `.soul-audit` | The staff log |
| `.soul-reviews`, `.soul-reviews__item`, `.bnb-catalogue` | Admin: SOUL requests and the Boons and Banes catalogue |
| `.pose--roll`, `.roll-details` | A roll result and its dice |

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
