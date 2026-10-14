# Inkwll

A web-first roleplaying game that mixes forum RP and MUSH: characters move
between rooms, and (soon) each room can hold several live, resumable scenes.

- **Design and decisions:** [`docs/design.md`](docs/design.md)
- **Decisions log:** [`docs/decisions.md`](docs/decisions.md)
- **Roadmap:** [`docs/roadmap.md`](docs/roadmap.md)
- **Task board:** [`tasks/README.md`](tasks/README.md)
- **Rules for AI helpers:** [`AGENTS.md`](AGENTS.md), and
  [`docs/ai-handoff.md`](docs/ai-handoff.md) for handing tasks to other AIs
- **What changed recently:** [`CHANGELOG.md`](CHANGELOG.md)

Built with Ruby on Rails 8, Hotwire (Turbo + Stimulus) and PostgreSQL.

## Running it

You need Ruby (version in `.ruby-version`) and PostgreSQL running.

```sh
bundle install
bin/rails db:prepare   # creates the database and adds the placeholder rooms
bin/dev                # starts the site at http://localhost:3000
```

Then sign up, create a character, and you'll appear in the starting Setting.

To make your account the first Founder (top-level staff, with the admin panel):

```sh
bin/rails "inkwll:make_founder[YourPlayerName]"
```

## Checking your work

```sh
bin/rails test   # automated tests
bin/rubocop      # code style
bin/brakeman     # security scan
```

GitHub Actions runs all of these on every pull request and every push to main.

## Where things live

| What | Where |
| --- | --- |
| Data (accounts, characters, rooms…) | `app/models/` |
| Page logic | `app/controllers/` |
| Page templates (HTML) | `app/views/` |
| Styles (colours and fonts are CSS variables at the top) | `app/assets/stylesheets/application.css` |
| Small bits of JavaScript | `app/javascript/controllers/` |
| Database changes | `db/migrate/` |
| Tests | `test/` |
