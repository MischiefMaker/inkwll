# Guide for AI helpers

This file is for any AI working on Inkwll: Claude, ChatGPT, Gemini, Copilot or anything else. Read it before changing anything.

## What Inkwll is

A web-only roleplaying game that mixes forum RP and MUSH play. Players move between rooms, each room can hold many live scenes at once, and finished scenes become logs. Inspired by AresMUSH, but with no telnet.

Stack: Ruby on Rails 8, Hotwire (Turbo + Stimulus), PostgreSQL. Hosted on one DigitalOcean server, deployed with Kamal.

## Who you are working for

The owner is comfortable with HTML and CSS but is not an experienced programmer.

- Make small, targeted changes. Do not redesign, rename or reorganize things you were not asked to touch.
- Explain what you changed and why in plain language.
- Do not invent APIs or library behavior. If you are unsure how something works, say so.
- Anything marked **[Proposed]** is not settled. Ask the owner before building on it.
- Do not add services that need extra hosting (for example Redis).
- Give every element you add a meaningful CSS class, so games can skin everything. Use the naming in `docs/css-classes.md` (`block`, `block__part`, `block--kind`), with plain words rather than the themed words players see, and add new classes to that file.

## Security checklist

- Never use `html_safe` or `raw` on anything a player wrote.
- Every new controller action checks who is allowed to do it, and gets a test that someone who isn't allowed is turned away.
- Every new form that posts something gets a rate limit (`limit_posting` in `ApplicationController`).
- Uploads stay image-only and size-limited.
- No secrets (passwords, keys) in git. They go in Kamal secrets on the server.

## Where things live

| Path | What it holds |
| --- | --- |
| `docs/design.md` | How the game works: the full design. |
| `docs/decisions.md` | Every decision the owner has made, newest first, with the date. |
| `docs/roadmap.md` | The build order and which step is current. |
| `docs/ai-handoff.md` | How the owner hands a task to another AI and brings the result back. |
| `docs/email-setup.md` | How to connect the game's email (Brevo). |
| `docs/wells.md` | The Founder's Wells page: updating games and launching new ones. |
| `docs/css-classes.md` | The CSS classes games can use to skin the site. |
| `docs/templates-proposal.md` | [Proposed] Letting games change page layouts, after studying Jcink's templates. |
| `tasks/` | One file per piece of work, plus the task board in `tasks/README.md`. |
| `tasks/inbox/` | Answers from outside AIs, waiting to be reviewed. |
| `CHANGELOG.md` | A short, plain-language list of what changed. |
| Everything else | The Rails app. |

## Keeping the records current

When your work changes one of these, update it in the same change:

- A new owner decision goes in `docs/decisions.md`, and `docs/design.md` if it changes how the game works.
- Finishing or starting a roadmap step updates `docs/roadmap.md`.
- Working on a task updates its status in the task file and on the board in `tasks/README.md`.
- A change people would notice gets a line in `CHANGELOG.md`.

## If you were handed a single task

You may only be seeing one task file, not this whole repository. In that case:

- Do only what the task asks. Stay inside the files it lists.
- If something is unclear, write your question at the top of your answer instead of guessing.
- Reply in the format the task's "What to send back" section asks for.
