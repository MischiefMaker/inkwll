# Decisions

Every choice the owner has settled, newest first. Each entry says what was decided and, where it helps, why.

Only things the owner decided go here. Ideas that still need the owner's yes are marked **[Proposed]** in `design.md` until they are settled.

To add one: copy an entry, put it at the top, and fill in today's date.

---

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
