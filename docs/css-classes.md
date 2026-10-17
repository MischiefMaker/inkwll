# CSS classes for skins

Every part of every page has a CSS class, so a game can restyle anything without touching the code. This is a guide to the main ones. To see the class of anything on a page, right-click it and choose **Inspect**.

## How the names work

- **Blocks and parts:** `.pose` is a block, `.pose__name` is a part of it, and `.pose--ooc` is a kind of it. So `.pose--narration .pose__body` means "the text of a narration post".
- **Colours, fonts and spacing** are CSS variables at the top of `app/assets/stylesheets/application.css` (`--font-body`, `--font-heading`, `--color-accent` and so on; Admin → Look sets most of them). Changing those restyles the whole site at once.
- **`--font-title`** is the Look's "Font for big titles". The front page's name (`.game-intro__title`) and forum section titles (`.forum-section__title`) use it, and a game's own CSS can use `font-family: var(--font-title)` for other titles.
- **Fonts** come with each game's world pack, not with Inkwll (see `SkinFont` and `docs/world-packs.md`); the family names are listed in Admin → Look. Fonts from other sites (Google Fonts and the like) are blocked by the Content Security Policy.
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
| `.layout--tabs-left`, `.has-chapter-tabs-left` (on `body`), `.chapter-tabs-side-field` | Chapter tabs down the left-hand side (Admin → Look), instead of along the top |
| `.admin-batch`, `.admin-batch__label`, `.admin-batch__heading`, `.admin-batch__all`, `.admin-batch__cell`, `.admin-batch__tick`, `.admin-characters__batch`, `.admin-accounts`, `.admin-accounts__batch` | Tick boxes on the admin lists, and the form that acts on every ticked row |
| `.draft-note`, `.draft-note__use`, `.draft-note__discard` | The note above a writing box when an unposted draft was kept |
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
| `.icon`, `.icon--home` (and `--characters`, `--messages`, `--door`, `--compass`, `--bookshelf` (the Bookshelf link) and the rest, named as in `app/helpers/icons_helper.rb`) | Inkwll's built-in line icons. They take the colour of the text around them |
| `.banner-default` | The drawn banner (accent colour with ink lines) on an Area or Setting that has no banner picture. It also has `.place__banner` on front-page cards and `.description-image` on Area and Setting pages |
| `.nib-icon`, `.nib-icon__back`, `.nib-icon__nib`, `.nib-icon__slit`, `.nib-icon__hole`, `.player-icon--default` | The pen-nib player icon shown when a player has no icon picture (guests get a grey one) |
| `.icon-tile`, `.icon-tile--compass` (Areas), `--door` (Settings), `--board` (boards) | The drawn icon shown on an Area, Setting or board that has no icon picture of its own. It also keeps the class an uploaded icon would have (`.place__icon`, `.board__icon`) |
| `.switcher`, `.switcher__gm` (the GM choice) | "Playing as" character picker |
| `.chapter-tabs`, `.chapter-tabs--collapsed`, `.chapter-tabs__list`, `.chapter-tab-wrap`, `.chapter-tab`, `.chapter-tab--current`, `.chapter-tab__title`, `.chapter-tab__setting`, `.chapter-tab__turn`, `.chapter-tab__unread` | Your Chapter tabs |
| `.chapter-tabs__toggle`, `.chapter-tabs__toggle-open`, `.chapter-tabs__toggle-closed`, `.chapter-tabs__arrow`, `.chapter-tabs__turn-flag` | The button that folds the tabs away, and the wiggling quill shown while folded when it's your turn |
| `.chapter-tab__close`, `.chapter-tab__close-form` | The X on a finished Chapter's tab |
| `.room-index`, `.room-index--depth-1`, `.room-index__area`, `.room-index__rooms`, `.room-index__room` | All Places, grouped by Area |
| `.writing-as`, `.writing-as__form`, `.writing-as__label`, `.writing-as__warning`, `.writing-as__warning-text`, `.writing-as__join`, `.writing-as__keep` | The "Writing as" switcher above the Passage box and its warning |
| `.admin-characters__active`, `.admin-characters__section`, `.admin-characters__summary`, `.admin-characters__approved`, `.admin-characters__new`, `.admin-characters__roster`, `.admin-characters__roster-table`, `.admin-characters__retired`, `.admin-characters__retired-table` | Admin → Characters: the working list and the retired section |
| `.directory-tabs__set`, `.directory-tabs__set--main`, `.directory-tabs__set--other`, `.directory-tabs__tab--active` | The Directory's tabs: Active and the groups, then the Roster and Unapproved set apart |
| `.directory__tag--played`, `.roster-apply__played` | The "Previously played" mark on roster characters |
| `.character-form__locked-value`, `.profile-field-form__player-can-edit` | A profile answer locked after approval; the "Player can edit" tick box |
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
| `.exits--street`, `.exits--building`, `.exits--unit`, `.exit-link--street`, `.exit-link--building`, `.exit-link--unit`, `.exit-link--out`, `.room-paths__heading`, `.room-paths__heading--street`, `.room-paths__heading--building`, `.room-paths__heading--outdoor`, `.room-paths__heading--other`, `.exits--outdoor`, `.exits--other`, `.room-paths__heading--unit`, `.exit-kind`, `.compass__centre--out` | Path types: streets, buildings to go into, units, and the way Out |
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
| `.guide`, `.guide__intro`, `.guide__heading`, `.guide__section`, `.guide__section--first-steps` (and `--places`, `--scenes`, `--characters`, `--talking`, `--staff`, `--from-mush`, `--from-forum`), `.guide__steps`, `.guide__step`, `.guide__subheading`, `.guide__list`, `.guide__terms`, `.guide__join`, `.menu__guide` | The players' Getting started page and its Menu link |
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
| `.profile-tabs`, `.profile-tabs__tab`, `.profile-tabs__tab--current` `.application-tabs`, `.application-tabs__tab`, `.application-panel` | The tabs on a character's profile, and on a staff application review |
| `.profile-fields`, `.profile-fields__row`, `.profile-fields__private`, `.details-list__term`, `.details-list__value` | Profile answers, such as Demographics |
| `.profile-fields__picture`, `.profile-field-input__picture`, `.profile-field-input__remove` | Picture answers: on the profile, and the current picture in the character form |
| `.application-status`, `.application-status--draft`, `--submitted`, `--returned` | The approval notice on a character |
| `.gallery`, `.gallery__item`, `.gallery__image`, `.gallery__caption` | The picture gallery |
| `.relationships`, `.relationships__item`, `.relationships__name`, `.relationships__kind`, `.relationships__note` | Relationships |
| `.player-profile`, `.player-profile__header`, `.player-profile__about`, `.player-characters` | A player's profile |
| `.player-icon`, `.player-icon--tiny`, `--large`, `--image`, `--guest`, `--default` | Player icons |
| `.character-profile--on-roster`, `.roster-status`, `.roster-status--on-roster`, `--requested`, `.roster-status__note`, `.roster-status__apply` | Roster notices on a character |
| `.roster-apply`, `.roster-apply__form`, `.roster-apply__question`, `.roster-apply__resubmit` | Applying for (or claiming) a roster character |
| `.directory`, `.directory__filter`, `.directory__list`, `.directory__item`, `.directory__item--roster`, `.directory__name`, `.directory__tag`, `.directory__tag--status`, `.directory-tabs`, `.directory-tabs__tab` (and `--all`, `--group`, `--roster`, `--unapproved`, `--current`) | The character directory and the Roster page |
| `.roster-admin`, `.roster-admin__item--application`, `--request`, `--character`, `.roster-admin__actions`, `.roster-admin__answers`, `.roster-admin__question`, `.roster-admin__answer` | Admin: the Roster page |
| `.character-form__roster` | "If you stop playing" on the character form |
| `.table__row--archived`, `.account-archived`, `.account-actions` | Archived accounts in Players and staff |
| `.account-password`, `.account-password__link`, `.account-password__link-field`, `.account-password__button` | The Password section on a player's page in Players and staff |
| `.character-name`, `.character-name--grouped`, `.character-group-<id>` | A character's name; grouped names take the group's colour from `--group-colour` |
| `.factions`, `.factions__intro`, `.factions__list`, `.factions__item`, `.factions__item--secret`, `.factions__name`, `.factions__tag`, `.factions__tag--secret`, `.factions__count`, `.factions__description` | The Factions page |
| `.faction`, `.faction--secret`, `.faction__name`, `.faction__secret`, `.faction__description`, `.faction__members`, `.faction__list`, `.faction__member`, `.faction__member--head`, `.faction__member--secret`, `.faction__member-link`, `.faction__member-name`, `.faction__title`, `.faction__member--npc`, `.faction__npc-name`, `.faction__staff-run`, `.faction__tag` (`--head`, `--npc`, `--roster`, `--secret`), `.faction__manage`, `.faction__manage-summary`, `.faction__manage-form`, `.faction__remove`, `.faction__leave`, `.faction__add`, `.faction__add-form` | One faction's page: its members, and the heads' and staff's controls |
| `.faction__requests`, `.faction__request-list`, `.faction__request`, `.faction__request-note`, `.faction__request-actions`, `.faction__accept`, `.faction__decline`, `.faction__join`, `.faction__join-waiting`, `.faction__join-form`, `.faction__join-who`, `.faction__withdraw`, `.faction__withdraw-form`, `.factions__tag--waiting`, `.alerts__faction` | Requests to join a faction: asking, and the heads' and staff's answer |
| `.character-profile__factions`, `.character-profile__faction`, `.character-profile__faction--secret` | The factions line under a character's name on their profile |
| `.character-form__factions`, `.character-form__faction-choices`, `.character-form__faction-legend`, `.character-form__faction` | Picking factions on the character form |
| `.factions-admin`, `.factions-admin__secret`, `.factions-admin__closed`, `.factions-admin__off`, `.factions-admin__heads-tip`, `.factions-admin__run-by`, `.factions-admin__staff-run`, `.faction-form` | Admin → Factions |
| `.application-review__factions`, `.inkling__share--faction`, `.inkling__share-form--faction` | Factions on an application, and sharing an Inkling with a faction |
| `.pose__details`, `.mini-profile__details`, `.character-profile__group`, `.directory__group` | The group and chosen fields beside Passages and on profiles |
| `.alert-bell`, `.alert-bell--unread`, `.alert-bell__number`, `.alerts`, `.alerts__item`, `.alerts__item--passage`, `--turn`, `--mention`, `--finished`, `--unread` | The alerts bell and the alerts list |
| `.alerts__staff`, `.alerts__staff-title`, `.alerts__staff-list`, `.alerts__staff-item` (and `--applications`, `--roster`, `--soul`, `--inklings`, `--grimoire`, `--reports`, `--update` for the Founder's "Update available"), `.alerts__staff-link`, `.alerts__staff-count` | What is waiting on staff, at the top of the bell's list |
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
| `.wiki-body__grouped` | A bullet that names a character group (a house, a faction). It gets `--group-colour` set to that group's colour, and the text and bullet use it |
| `.wiki-embed`, `.wiki-embed--characters` (and the other list names), `.wiki-embed--unknown` | A live list inside a page |
| `.wiki-characters`, `.wiki-character`, `.wiki-manuscripts`, `.wiki-settings`, `.wiki-pages-list` (each with `__item` and `__name` or `__title`) | The lists themselves |
| `.wiki-form`, `.wiki-form__body`, `.wiki-form__help` | Writing a page |
| `.wiki-history`, `.wiki-history__item`, `.wiki-history__current` | A page's history |
| `.wiki-form__tabs`, `.wiki-form__tab` | The Edit / Preview tabs on the wiki page form (`.is-current` marks the open one) |
| `.wiki-form__preview` | The box that shows the preview of a wiki page |
| `.visibility-mark` | A small sign for who can see something. Kinds: `.visibility-mark--you-and-staff` (shield), `.visibility-mark--you-only` (open eye), `.visibility-mark--staff-only` (star). Its icon classes are `.icon--shield`, `.icon--lock` (the locked kind, `.visibility-mark--locked`), `.icon--eye` and `.icon--star` |
| `.profile-box` | The box with a character's icon, name, details and buttons. `.profile-box--top` goes across the top, `.profile-box--side` down the side (Admin > Look). Parts: `.profile-box__portrait`, `.profile-box__heading`, `.profile-box__facts` (the short demographics), `.profile-box__actions` |
| `.character-profile--box-top`, `.character-profile--box-side` | The whole character profile, set by where the box goes |
| `.profile-tab__empty` | "Nothing more to show here." on a Profile tab with no long answers |
| `.admin-quick` | The row of quick-action buttons on the admin front page. Each is `.admin-quick__button` plus `.admin-quick__button--character`, `--place`, `--area`, `--wiki`, `--players`, `--characters`, `--applications`, `--reports`, `--bans` or `--settings` |
| `.admin-attention` | The "Needs Attention" box on the admin front page: `.admin-attention__heading`, `.admin-attention__list`, `.admin-attention__item` (with `--applications`, `--roster`, `--soul`, `--inklings`, `--grimoire`, `--reports`), `.admin-attention__link`, `.admin-attention__label`, `.admin-attention__count`, `.admin-attention__empty` |
| `.player-list` | The Players page: `.player-list__intro`, `.player-list__items`, `.player-list__item`, `.player-list__link`, `.player-list__name` |
| `.game-stats` | The counts at the bottom of the front page. Each is `.game-stats__item` with `--players`, `--characters`, `--chapters` or `--archives`, holding `.game-stats__icon`, `.game-stats__label` (also `.game-stats__link` when it is a link) and `.game-stats__count` |
| `.character-inklings` | The Inklings tab on a character profile: `.character-inklings__heading`, `__item`, `__title`, `__when`, `__empty` |
| `.menu__wiki-page` | A wiki page listed in the Menu (indented under Wiki) |
| `.menu__wiki-dot` | The small filled dot before a wiki page in the Menu |
| `.storyteller-tools`, `.storyteller-tools__call`, `.storyteller-tools__sheets`, `.storyteller-tools__award`, `.storyteller-sheet`, `.storyteller-sheet__name`, `.storyteller-sheet__aspect`, `.storyteller-sheet__skills` | A Chapter's Storyteller tools |
| `.soul-reviews__item--award` | Admin: XP a Storyteller suggested |
| `.features`, `.features__item` | Admin: Features |
| `.wells__list`, `.wells__well`, `.wells__version`, `.wells__current`, `.wells__busy`, `.wells__status` (`--current`/`--available`), `.wells__home`, `.wells__setup-link`, `.wells__import-link`, `.wells__release--newest`, `.wells__older`, `.wells__older-summary`, `.wells__install-all`, `.wells__new`, `.wells__address`, `.wells__slug`, `.wells__start`, `.wells__well--starting`/`--live`/`--failed`, `.wells__setup`, `.wells__steps`, `.wells__error`, `.wells__releases`, `.wells__release` (`--current`), `.wells__release-name`, `.wells__release-notes`, `.wells__release-current`, `.wells__release-waiting`, `.wells__install` (button), `.wells__updates`, `.wells__update`, `.wells__update--done`/`--failed`/`--working` (rows) | Admin: Wells (Founder only) |
| `.version-footer` | The small "Inkwll v1.0" line at the bottom of every page |
| `.admin-setup`, `.admin-setup__look` | "Pick your game's look" on the admin Overview |
| `.skin-presets`, `.skin-preset`, `.skin-preset__swatch`, `.skin-preset__current`, `.skin-form`, `.skin-form__row`, `.skin-form__colour`, `.skin-form__css`, `.skin-fonts`, `.skin-fonts__list`, `.skin-fonts__item`, `.skin-fonts__name`, `.skin-fonts__form` | Admin: Look, and the list of the game's own fonts under it |
| `.inklings-admin`, `.inklings-admin--waiting` | Admin: Inklings |
| `.bulk-build`, `.bulk-build__rooms`, `.bulk-build__room`, `.bulk-build__room-number`, `.bulk-build__paths`, `.bulk-build__path`, `.bulk-build__room-select`, `.bulk-build__new-rooms`, `.bulk-build__add`, `.bulk-build__remove`, `.bulk-build__submit` | Admin: Build several Settings |
| `.game-status`, `.game-time`, `.game-time__date`, `.game-time__weather`, `.online-now`, `.online-now__list`, `.online-now__player`, `.online-now__head`, `.online-now__title`, `.online-now__count`, `.online-now__where`, `.online-now__where-icon`, `.online-now__link`, `.online-now__name`, `.online-now__playing`, `.player-icon--small` | The game's date, weather and who's online, on the front page |
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
| `.pending-rolls`, `.pending-roll`, `.pending-roll__form`, `.pending-roll__bnbs`, `.pending-roll__no-bnbs`, `.storyteller-tools__bnbs`, `.storyteller-tools__bnb`, `.pending-roll__required`, `.roll-box__bnbs`, `.roll-box__bnb` | Rolls waiting for the Storyteller |
| `.soul-bnbs`, `.soul-bnb`, `.soul-bnb--boon`, `--bane`, `--resolved`, `.soul-bnb__name`, `.soul-bnb__kind`, `.soul-bnb__explanation` | Boons and Banes on the sheet |
| `.soul-culminations`, `.soul-culmination`, `.soul-culmination--approved` (and the other statuses) | Culminations |
| `.soul-history`, `.soul-history__item` | Narrative History |
| `.soul-audit` | The staff log |
| `.rating-guide`, `.rating-guide__button`, `.rating-guide__label`, `.rating-guide__popover`, `.rating-guide__title`, `.rating-guide__list`, `.rating-guide__item`, `.rating-guide__range`, `.rating-guide__name`, `.rating-guide__about`, `.soul-admin__guide`, `.soul-admin__guide-table`, `.soul-admin__guide-item`, `.soul-admin__guide-add` | The "i" pop-up on the SOUL sheet saying what ratings mean, and its admin editor |
| `.soul-reviews`, `.soul-reviews__item`, `.bnb-catalogue`, `.bnb-catalogue__actions`, `.bnb-catalogue__edit`, `.bnb-catalogue__delete`, `.bnb-catalogue__delete-form`, `.icon-action`, `.icon-action--edit`, `.icon-action--delete`, `.icon-action-form` (pencil and trashcan buttons, via `edit_icon_link` and `delete_icon_button`) | Admin: SOUL requests and the Boons and Banes catalogue |
| `.pose--roll`, `.roll-details` | A roll result and its dice |

## Chapters

| Class | What it is |
| --- | --- |
| `.scene`, `.scene__header`, `.scene__meta` | A Chapter page |
| `.scene__main`, `.scene__side`, `.scene__tools` | A Chapter's story column, and the side column (Place, people, writing tools) shown beside it on wide screens |
| `.scene-setting__where`, `.scene-setting__paths` | The Place's location line, and its Paths on the right |
| `.scene--layout-manuscript`, `.scene--layout-forum`, `.scene--layout-chat`, `.scene--cast-large`, `.scene--cast-small`, `.scene--portraits-large`, `.scene--portraits-small`, `.scene__kicker` | The Chapter layout chosen in Admin → Look, and the "Chapter 12" line above the title |
| `.cast-cards`, `.cast-card`, `.cast-card--turn`, `.cast-card__button`, `.cast-card__name`, `.cast-card__details`, `.cast-card__turn` | Manuscript's cards for the cast under the title, and whose turn it is |
| `.scene-setting`, `.scene-setting__name`, `.scene-setting__description`, `.scene-setting__here` | The Setting box at the top |
| `.scene-people`, `.scene-people__list`, `.scene-people__actions` | Who's in it, and Leave / Pause / Finish |
| `.turn-bar`, `.turn-bar__text`, `.turn-bar__timer`, `.turn-bar__warning` | Whose turn it is |
| `.passages` | All the posts |
| `.passages__earlier`, `.passages__whole` | The "Read the whole chapter" link above the latest posts, and the note on the whole-chapter page |
| `.pose`, `.pose__icon`, `.pose__name`, `.pose__time`, `.pose__body`, `.pose__actions` | One post |
| `.pose--passage`, `.pose--npc`, `.pose--narration`, `.pose--ooc`, `.pose--system` | Each kind of post |
| `.pose__tag`, `.pose__played-by` | The OOC / Narration tag, and "NPC, played by" |
| `.pose--with-author`, `.pose__author`, `.pose-break`, `.character-icon--portrait` | The picture-and-name column beside a Passage (Forum, or Manuscript with large pictures), the ✦ ✦ ✦ break after a long pause, and the tall portrait |
| `.chapter-look-field` | The Chapter layout choices in Admin → Look |
| `.composer`, `.composer__kinds`, `.composer__npc`, `.composer__warning` | The writing box |
| `.mini-profile` | The pop-up when you click a character |
| `.scene-list`, `.scene-list__title`, `.scene-list__meta` | A Setting's list of Chapters |
| `.manuscript`, `.manuscript__title`, `.manuscript__meta` | A finished Chapter in the Archives |
| `.character-icon`, `.character-icon--tiny`, `--small`, `--large`, `--initial`, `--npc`, `--gm` (GM posts with the player's picture) | Character icons |
| `.area-intro`, `.area-intro__banner`, `.area-intro__summary`, `.area-intro__name` | A Setting's Area (banner and short text) shown above the Setting's name |
| `.where-now__name` | The character's name in "[Character] is in [Place]" on the front page (Group colour, with a very small icon beside it) |
| `.switcher__menu`, `.switcher__current`, `.switcher__options`, `.switcher__option`, `.switcher__option--current`, `.switcher__name`, `.switcher__name--nobody`, `.switcher__icon`, `.switcher__gm` | The Playing as menu in the header: each character with their icon and Group colour |
| `.profile-field-form__age-on-passages` | The tick box for showing just the age beside Passages |
| `.game-icon`, `.game-icon--small`, `.game-icon--large`, `.game-icon--default`, `.site-header__name`, `.game-intro__title`, `.game-settings__icon` | The game's icon beside its name in the top bar (small) and the front page header (large) |
| `.chapter-tab__badges`, `.chapter-tab__quill` | The top-right corner of a Chapter tab: the twitching quill when it's your turn, and the unread count |
| `.turn-quill` | The twitching quill beside an Area, Setting, character or the "is in" line where it's your turn; a link to that Chapter |
| `.my-characters__group`, `.my-characters__group--none`, `.my-characters__heading`, `.my-characters__list`, `.my-characters__item`, `.my-characters__name` | My Characters: a section per Group, each character with their icon and the quill when it's their turn |
| `.character-chapters`, `.character-chapters__item` | The Active Chapters tab on a character profile (player and staff only) |
| `.admin-lock`, `.admin-lock--locked`, `.button--danger` | The Lock / Unlock the Game section on the admin page, and the red button style |
| `.game-locked`, `.game-locked__actions` | The page guests and non-staff players see while the game is locked |
| `.game-lock-banner` | The note staff see on every page while the game is locked |
| `.character-inklings__more`, `.character-inklings__link`, `.character-inklings__shared` | On a character's Inklings tab: the link to the Inklings page, and the mark on an Inkling shared with the character by another |

| `.profile-layout`, `.profile-menu`, `.profile-menu__group` (`--basics`, `--system`, `--writing`), `.profile-menu__heading`, `.profile-menu__list`, `.profile-menu__item`, `.profile-menu__link`, `.profile-menu__link--current` | A character profile's menu down the left (Basics: Profile, Application, Relationships, Image Gallery; System: SOUL, Inklings, Grimoire; Writing: Manuscripts, Active Chapters) with the chosen page beside it |
| `.roll-box__private` | The "Only me and staff see the result" checkbox in an Inkling's Roll a Skill |
| `.inkling-link-box`, `.inkling-link-box__open`, `.inkling-link-modal`, `.inkling-link-modal__form`, `.inkling-link-modal__new` | "Add to an Inkling" in a Chapter's tools: the button, and the pop-up that asks why |
| `.name-changes`, `.name-changes__row` (with `--player`, `--character`), `.name-changes__pages`, `.name-changes__empty` | Admin → Name changes: the log of renames |
| `.admin-delete`, `.admin-delete__button`, `.admin-delete__blocked` | The "Delete this Area/Place" box at the bottom of the admin edit pages |
| `.skill-checkboxes`, `.skill-checkboxes__group`, `.skill-checkboxes__aspect`, `.skill-checkboxes__option` | The tick-box list for picking Skills (grouped by Aspect) on Boons and Banes |
| `.modal`, `.modal__form`, `.modal__title`, `.modal__actions` | Any pop-up box (a `<dialog>`) |
| `.inkling-entry__chapter`, `.inkling-entry__chapter-link` | The "Chapter: …" line on an Inkling entry that came from a Chapter |
| `.inkling__cast` | "Cast a spell" in an Inkling (like `.inkling__roll`) |
| `.cast-box__empty` | The note in "Cast a spell" when the character hasn't learned any spells |
| `.inkling__chapters`, `.inkling__chapter` | The "Linked to:" line on an Inkling listing the Chapters it is linked to |
| `.roll-box__ask` | The "Roll with the Storyteller" button in Roll a Skill, only when the Chapter has a Storyteller |
| `.storyteller-tools__npc`, `.storyteller-tools__npc-form` | "Roll for an NPC" in the Storyteller tools |
| `.inklings-admin__filters`, `.inklings-admin__days`, `.inklings-admin__days--current` | The "Active in the last N days" choices above the admin Inklings list |
| `.chapter-index`, `.chapter-index__item` (`--joinable`, `--private`, `--hidden`), `.chapter-index__heading`, `.chapter-index__title` (`--closed`), `.chapter-index__status`, `.chapter-index__written`, `.chapter-index__turn`, `.chapter-index__paused`, `.chapter-index__intro`, `.chapter-index__archives`, `.chapter-index__archives-link` | The Open Chapters list under The world in the menu, and its pointer to the Archives |
| `.chapter-index-page`, `.chapter-index__main`, `.chapter-index__where`, `.chapter-index__people`, `.chapter-index__person` | The Open Chapters page: wider layout, each row's title and Place, and the people in it with their tiny icons |
