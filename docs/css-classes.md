# CSS classes for skins

Every part of every page has a CSS class, so a game can restyle anything without touching the code. This is a guide to the main ones. To see the class of anything on a page, right-click it and choose **Inspect**.

## How the names work

- **Blocks and parts:** `.pose` is a block, `.pose__name` is a part of it, and `.pose--ooc` is a kind of it. So `.pose--narration .pose__body` means "the text of a narration post".
- **Colours, fonts and spacing** are CSS variables at the top of `app/assets/stylesheets/application.css` (`--font-body`, `--font-heading`, `--color-accent` and so on; Admin → Look sets most of them). Changing those restyles the whole site at once.
- **Every page** puts classes on `<body>`: `page-scenes` (any Chapter page), `page-scenes-show` (just the Chapter itself), `page-admin-bans`, and so on. They are made from the page's address in the code, `page-<section>-<action>`. Add `is-logged-in` or `is-guest`, plus `is-staff` for staff, and `is-admin` on every admin panel page. Use them to style one page only, for example `.page-home-show .page-title`.
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
| `.look-fields`, `.field--picture`, `.field--icon`, `.field--image`, `.field--background`, `.image-preview`, `.image-preview--icon` | The "How it looks" pictures and text on Area, Setting and Look forms |
| `.button`, `.button--quiet`, `.button-link` | Buttons |
| `.badge`, `.tag` | Small labels ("Open", "Turn") |
| `.flash`, `.flash--notice`, `.flash--alert` | Messages after an action ("Saved.") |
| `.notice-box` | Boxed notices ("Paused since…", "Finished…") |
| `.breadcrumbs` | The Area names above a Setting |

## The frame

| Class | What it is |
| --- | --- |
| `.site-header`, `.site-header__nav`, `.site-header__account`, `.site-header__player`, `.site-header__link`, `.site-header__home`, `.site-header__characters`, `.site-header__icon`, `.site-header__label`, `.site-header__log-out`, `.message-count__icon` | The bar along the top (on phones `.site-header__label` is hidden, so the links show as icons only) |
| `.menu`, `.menu__items`, `.menu__link`, `.menu__icon`, `.menu__heading` (and `--mine`, `--world`, `--community`, `--staff`) | The Menu |
| `.icon`, `.icon--home` (and `--characters`, `--messages`, `--door`, `--compass` and the rest, named as in `app/helpers/icons_helper.rb`) | Inkwll's built-in line icons. They take the colour of the text around them |
| `.banner-default` | The drawn banner (accent colour with ink lines) on an Area or Setting that has no banner picture. It also has `.place__banner` on front-page cards and `.description-image` on Area and Setting pages |
| `.nib-icon`, `.nib-icon__back`, `.nib-icon__nib`, `.nib-icon__slit`, `.nib-icon__hole`, `.player-icon--default` | The pen-nib player icon shown when a player has no icon picture (guests get a grey one) |
| `.icon-tile`, `.icon-tile--compass` (Areas), `--door` (Settings), `--board` (boards) | The drawn icon shown on an Area, Setting or board that has no icon picture of its own. It also keeps the class an uploaded icon would have (`.place__icon`, `.board__icon`) |
| `.switcher`, `.switcher__gm` (the GM choice) | "Playing as" character picker |
| `.chapter-tabs`, `.chapter-tab`, `.chapter-tab--current`, `.chapter-tab__title`, `.chapter-tab__setting`, `.chapter-tab__turn`, `.chapter-tab__unread` | Your Chapter tabs |
| `.layout`, `.main` | The page body and its main column |
| `.ooc-sidebar`, `.ooc-sidebar__title`, `.ooc-sidebar__toggle`, `.ooc-sidebar__count`, `.ooc-sidebar--collapsed`, `.ooc-sidebar__arrow`, `.ooc-sidebar__tab-label` | The OOC Chat sidebar (on phones, `.ooc-sidebar__toggle` is the drop-down bar across its top) |
| `.layout--admin`, `.admin-menu`, `.admin-menu__button`, `.admin-menu__button-current`, `.admin-menu__body`, `.admin-menu__title`, `.admin-menu__group`, `.admin-menu__heading`, `.admin-menu__list`, `.admin-menu__item`, `.admin-menu__link`, `.admin-menu__link--overview`, `.admin-menu__label`, `.admin-menu__count`, `.is-current` | The admin panel's side menu (on phones it folds into `.admin-menu__button`) |
| `.ooc-message`, `.ooc-message__author`, `.ooc-message__author--guest`, `.ooc-message__time`, `.ooc-message__body`, `.player-icon`, `.player-icon--guest` | OOC Chat messages |
| `.ooc-message--deleted`, `.ooc-message__body--deleted`, `.ooc-message__edited`, `.ooc-message__actions`, `.ooc-message__action`, `.ooc-message__edit`, `.ooc-message__delete`, `.ooc-message__delete-form`, `.ooc-message__icon`, `.ooc-message__block`, `.ooc-edit`, `.ban-form__chat-only`, `.ban__chat-only`, `.can-ban` (on `body`) | Editing, deleting and blocking in the OOC Chat |

## Front page, Areas and Settings

| Class | What it is |
| --- | --- |
| `.game-intro`, `.game-intro__name`, `.game-intro__blurb` | The game's name and blurb at the top of the front page |
| `.places`, `.place`, `.place--banner`, `.place__banner`, `.place__body`, `.place__name`, `.place__icon`, `.place__title`, `.place__summary`, `.place__activity`, `.place__here`, `.place__latest` | One Area on the front page |
| `.place__actions`, `.place__enter`, `.place__shortcuts`, `.place__shortcuts-toggle`, `.place__shortcuts-list` | Its Enter button and the tucked-away shortcuts |
| `.board`, `.board__header`, `.board__title`, `.board__description`, `.board__rows`, `.board__row`, `.board__name`, `.board__icon`, `.board__summary` | The lists on an Area's page |
| `.room`, `.description-image`, `.lede`, `.page-title__icon` | A Setting's or Area's page: its banner, short text and icon |
| `.skin-mush` (on `<body>`), `--ansi-red`, `--ansi-green`, `--ansi-yellow`, `--ansi-blue`, `--ansi-magenta`, `--ansi-cyan`, `--ansi-white`, `--ansi-grey` | The Old-school MUSH look and its ANSI colours (each ready-made look adds `.skin-<name>` to `<body>`) |
| `--page-image`, `--box-image`, `--intro-image` | CSS variables holding the background pictures from Admin → Look (an Area's or Setting's own background sets `--page-image` on its page) |
| `.exits--street`, `.exits--building`, `.exits--unit`, `.exit-link--street`, `.exit-link--building`, `.exit-link--unit`, `.exit-link--out`, `.room-paths__heading`, `.room-paths__heading--building`, `.room-paths__heading--unit`, `.exit-kind`, `.compass__centre--out` | Path types: streets, buildings to go into, units, and the way Out |
| `.exit-link__direction`, `.exit-direction` | A Path's compass direction (NNW), on the Path and in the builder |
| `.compass`, `.compass__centre`, `.compass__point`, `.compass__point--main`, `.compass__point--path`, `.compass__point--disabled`, `.compass__point--n` ... `.compass__point--nnw`, `--compass-size`, `--angle` | The compass on a Setting's page |
| `.numbered-paths`, `.numbered-paths--apartments` (and `--hotel`, `--dorms`, `--offices`, `--street`, `--plain`), `.numbered-paths__title`, `.numbered-paths__count`, `.numbered-paths__filter`, `.numbered-paths__list`, `.numbered-paths__item` | A Setting's compact list of numbered Paths (apartments, hotel rooms...) |
| `.numbered-path`, `.numbered-path--disabled`, `.numbered-path__form`, `.numbered-path__number`, `.numbered-path__dash`, `.numbered-path__name` | One numbered door: "100 - Jaxon Marley" |
| `.scene-setting__numbered`, `.exit-number`, `.room-kind`, `.numbered-rooms-builder`, `.numbered-rooms-builder__form`, `.numbered-rooms-builder__lines` | Numbered doors in a Chapter's Setting box; the number tag, Setting type and "Add numbered settings" tool in the builder |
| `.room-ways` | The box holding a Setting's Paths and who is here |
| `.exits`, `.exit-link`, `.room-paths` | A Setting's Paths |
| `.room-here`, `.where-now` | Who is standing here |
| `.room-here__guests`, `.where-now--guest`, `.from-afar__preview` | Guests previewing: the "Guest" / "3 Guests" line under Here, and the notes asking them to log in |
| `.site-header--guest`, `.site-header__preview`, `.layout--guest`, `.main--preview`, `.main--narrow` | The top bar and page body for visitors who aren't logged in (`.main--narrow` on log in and sign up; `.guest-chat-hello` is the line there pointing guests to the OOC Chat) |
| `.place__preview`, `.exit-link--preview`, `.numbered-path--preview`, `.compass__point--preview`, `.compass__centre--preview` | The Preview button and Paths shown as plain links to guests |
| `.where-room`, `.where-room__areas`, `.where-room__list` | The Where list |
| `.guide`, `.guide__intro`, `.guide__heading`, `.guide__section`, `.guide__section--first-steps` (and `--places`, `--scenes`, `--characters`, `--talking`, `--staff`), `.guide__steps`, `.guide__step`, `.guide__join`, `.menu__guide` | The players' Getting started page and its Menu link |
| `.guide--admin`, `.guide__section--setup`, `.guide__section--daily`, `.guide__who`, `.admin-menu__link--guide`, `.admin-guide-link` | The staff Getting started page and its links in the admin panel |

## Forum boards

| Class | What it is |
| --- | --- |
| `.forum-section`, `.forum-section__title`, `.forum-section__boards` | The boards section on the front page, after the Areas |
| `.forum-board`, `.forum-board__banner`, `.forum-board__icon`, `.forum-board__body`, `.forum-board__name`, `.forum-board__title`, `.forum-board__summary`, `.forum-board__activity`, `.forum-board__count`, `.forum-board__latest`, `.forum-board__actions`, `.forum-board__open` | One board's card (it also has the Area card classes `.place`, `.place__name` and so on, so it looks like an Area) |
| `.forum-board-page__name`, `.forum-board-page__description`, `.forum-board-page__rules`, `.forum-board-page__start` | A board's own page |
| `.forum-topics`, `.forum-topic-row`, `.forum-topic-row--pinned`, `.forum-topic-row--locked`, `.forum-topic-row__title`, `.forum-topic-row__badge`, `.forum-topic-row__starter`, `.forum-topic-row__replies`, `.forum-topic-row__latest`, `.forum-topics__latest-heading` | The list of threads on a board |
| `.forum-topic__title`, `.forum-topic__meta`, `.forum-topic__badge`, `.forum-topic__edit`, `.forum-topic__closed` | A thread's page |
| `.forum-posts`, `.forum-post`, `.forum-post__header`, `.forum-author`, `.forum-post__time`, `.forum-post__edited`, `.forum-post__actions`, `.forum-post__body` | Posts in a thread |
| `.forum-pages`, `.forum-pages__link`, `.forum-pages__link--current` | Page numbers on long boards and threads |
| `.forum-topic-form`, `.forum-reply-form`, `.forum-post-form`, `.forum-board-form`, `.forum-boards-admin` | Forms, and the admin list of boards |

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
| `.profile-fields__picture`, `.profile-field-input__picture`, `.profile-field-input__remove` | Picture answers: on the profile, and the current picture in the character form |
| `.application-status`, `.application-status--draft`, `--submitted`, `--returned` | The approval notice on a character |
| `.gallery`, `.gallery__item`, `.gallery__image`, `.gallery__caption` | The picture gallery |
| `.relationships`, `.relationships__item`, `.relationships__name`, `.relationships__kind`, `.relationships__note` | Relationships |
| `.player-profile`, `.player-profile__header`, `.player-profile__about`, `.player-characters` | A player's profile |
| `.player-icon`, `.player-icon--tiny`, `--large`, `--image`, `--guest`, `--default` | Player icons |
| `.character-profile--on-roster`, `.roster-status`, `.roster-status--on-roster`, `--requested`, `.roster-status__note`, `.roster-status__apply` | Roster notices on a character |
| `.roster-apply`, `.roster-apply__form`, `.roster-apply__question`, `.roster-apply__resubmit` | Applying for (or claiming) a roster character |
| `.directory`, `.directory__filter`, `.directory__list`, `.directory__item`, `.directory__item--roster`, `.directory__name`, `.directory__tag` | The character directory and the Roster page |
| `.roster-admin`, `.roster-admin__item--application`, `--request`, `--character`, `.roster-admin__actions`, `.roster-admin__answers`, `.roster-admin__question`, `.roster-admin__answer` | Admin: the Roster page |
| `.character-form__roster` | "If you stop playing" on the character form |
| `.table__row--archived`, `.account-archived`, `.account-actions` | Archived accounts in Players and staff |
| `.account-password`, `.account-password__link`, `.account-password__link-field`, `.account-password__button` | The Password section on a player's page in Players and staff |
| `.character-name`, `.character-name--grouped`, `.character-group-<id>` | A character's name; grouped names take the group's colour from `--group-colour` |
| `.pose__details`, `.mini-profile__details`, `.character-profile__group`, `.directory__group` | The group and chosen fields beside Passages and on profiles |
| `.alert-bell`, `.alert-bell--unread`, `.alert-bell__number`, `.alerts`, `.alerts__item`, `.alerts__item--passage`, `--turn`, `--mention`, `--finished`, `--unread` | The alerts bell and the alerts list |
| `.alert-menu`, `.alert-menu__summary`, `.alert-menu__panel`, `.alert-menu__frame` | The bell's drop-down in the header |
| `.chapter-tracker`, `.chapter-tracker__character`, `.chapter-tracker__row`, `.chapter-tracker__row--my-turn`, `.chapter-tracker__subtitle` | My Chapters |
| `.inklings`, `.inklings__item`, `.inklings__item--unread`, `--draft`, `--submitted`, `--approved`, `--needs_changes`, `.inklings__type`, `.inklings__type--<type>`, `.inklings__start-disabled`, `.inklings__why-not`, `.button--disabled` | The Inklings list |
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
| `.storyteller-tools`, `.storyteller-tools__call`, `.storyteller-tools__sheets`, `.storyteller-tools__award`, `.storyteller-sheet`, `.storyteller-sheet__name`, `.storyteller-sheet__aspect`, `.storyteller-sheet__skills` | A Chapter's Storyteller tools |
| `.soul-reviews__item--award` | Admin: XP a Storyteller suggested |
| `.features`, `.features__item` | Admin: Features |
| `.admin-setup`, `.admin-setup__look` | "Pick your game's look" on the admin Overview |
| `.skin-presets`, `.skin-preset`, `.skin-preset__swatch`, `.skin-preset__current`, `.skin-form`, `.skin-form__row`, `.skin-form__colour`, `.skin-form__css` | Admin: Look |
| `.inklings-admin`, `.inklings-admin--waiting` | Admin: Inklings |
| `.bulk-build`, `.bulk-build__rooms`, `.bulk-build__room`, `.bulk-build__room-number`, `.bulk-build__paths`, `.bulk-build__path`, `.bulk-build__room-select`, `.bulk-build__new-rooms`, `.bulk-build__add`, `.bulk-build__remove`, `.bulk-build__submit` | Admin: Build several Settings |
| `.game-status`, `.game-time`, `.game-time__date`, `.game-time__weather`, `.online-now`, `.online-now__list`, `.online-now__player` | The game's date, weather and who's online, on the front page |
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
| `.soul-reviews`, `.soul-reviews__item`, `.bnb-catalogue`, `.bnb-catalogue__actions`, `.bnb-catalogue__edit`, `.bnb-catalogue__delete`, `.bnb-catalogue__delete-form`, `.icon-action` (pencil and trashcan buttons) | Admin: SOUL requests and the Boons and Banes catalogue |
| `.pose--roll`, `.roll-details` | A roll result and its dice |

## Chapters

| Class | What it is |
| --- | --- |
| `.scene`, `.scene__header`, `.scene__meta` | A Chapter page |
| `.scene-setting`, `.scene-setting__name`, `.scene-setting__description`, `.scene-setting__here` | The Setting box at the top |
| `.scene-people`, `.scene-people__list`, `.scene-people__actions` | Who's in it, and Leave / Pause / Finish |
| `.turn-bar`, `.turn-bar__text`, `.turn-bar__timer`, `.turn-bar__warning` | Whose turn it is |
| `.passages` | All the posts |
| `.passages__earlier`, `.passages__whole` | The "Read the whole chapter" link above the latest posts, and the note on the whole-chapter page |
| `.pose`, `.pose__icon`, `.pose__name`, `.pose__time`, `.pose__body`, `.pose__actions` | One post |
| `.pose--passage`, `.pose--npc`, `.pose--narration`, `.pose--ooc`, `.pose--system` | Each kind of post |
| `.pose__tag`, `.pose__played-by` | The OOC / Narration tag, and "NPC, played by" |
| `.composer`, `.composer__kinds`, `.composer__npc`, `.composer__warning` | The writing box |
| `.mini-profile` | The pop-up when you click a character |
| `.scene-list`, `.scene-list__title`, `.scene-list__meta` | A Setting's list of Chapters |
| `.manuscript`, `.manuscript__title`, `.manuscript__meta` | A finished Chapter in the Archives |
| `.character-icon`, `.character-icon--tiny`, `--small`, `--large`, `--initial`, `--npc`, `--gm` (GM posts with the player's picture) | Character icons |
| `.area-intro`, `.area-intro__banner`, `.area-intro__summary`, `.area-intro__name` | A Setting's Area (banner and short text) shown above the Setting's name |
