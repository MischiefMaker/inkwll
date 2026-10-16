# Deploying Inkwll

Inkwll runs on one DigitalOcean droplet, deployed with Kamal from Claude's
cloud environment. The game and its PostgreSQL database run side by side on
the droplet in Docker.

## What lives where

| What | Where |
| --- | --- |
| How it's deployed | `config/deploy.yml` (no secrets) |
| Where secrets come from | `.kamal/secrets` (no secrets, just where to read them) |
| The secrets themselves | `deploy/secrets.env` in the project files, never in git |
| The key Claude logs in to the droplet with | `deploy/inkwll-deploy` in the project files (the public half was pasted into DigitalOcean) |

## The droplet

- Basic, Regular, 1 GB memory, Ubuntu 24.04, with DigitalOcean backups on.
- The game answers at https://inkwll.com (www.inkwll.com sends visitors on
  to it). The domain is registered at Namecheap; under Advanced DNS it has an
  A record for `@` with the droplet's IP and a CNAME for `www` to inkwll.com.
- kamal-proxy gets free HTTPS certificates from Let's Encrypt, so the DNS
  must point at the droplet before a deploy. Another game sets its own domain
  with `INKWLL_DOMAIN` (see `config/deploy.yml`).

## Deploying

Claude's cloud environment can't open SSH connections, so deploys run on
GitHub Actions: **Actions → Deploy → Run workflow** (tick "First deploy" the
first time). It only runs when started by hand, and Claude asks the owner
before starting it.

It needs these in the repository's **Settings → Secrets and variables → Actions**:

| Name | Kind | Value |
| --- | --- | --- |
| `INKWLL_SERVER` | Variable | The droplet's IP address |
| `DEPLOY_SSH_KEY` | Secret | The whole of `deploy/inkwll-deploy` from the project files |
| `SECRET_KEY_BASE` | Secret | The `SECRET_KEY_BASE` line's value from `deploy/secrets.env` |
| `DATABASE_PASSWORD` | Secret | The `DATABASE_PASSWORD` line's value from `deploy/secrets.env` |
| `WELLS_GITHUB_TOKEN` | Secret | Optional. The token for the Founder's Wells page (see `docs/wells.md`) |
| `DIGITALOCEAN_TOKEN` | Secret | Optional. Lets a new Well's subdomain be made in DigitalOcean's DNS (domain scope only) |

Other Wells on the droplet keep their own passwords in `/root/wells/<short name>.env` on the droplet, and their backups in `/root/backups/<short name>-before-update-*`.

Every deploy except the first backs up the database on the droplet first, to
`/root/backups/before-update-<date>.sql.gz`. The newest ten are kept. If the
backup fails, nothing is deployed.

The Founder can also update from **Admin → Wells**, which runs this same
workflow with a version marked ready. See `docs/wells.md`.

To make a registered player the Founder on the live game, run the same
workflow with their player name in "make Founder" (it doesn't deploy).

To see the live game's recent logs, run **Actions → Show logs**. It only
reads; nothing on the droplet changes, so Claude runs it without asking.

Logins last a year over HTTPS. A game run on plain http (no domain, with
`INKWLL_HTTPS: "false"`) gets logins that last until the browser is closed,
because browsers such as Firefox won't keep a long-lived login cookie from
an http site.

GitHub keeps secrets hidden: nobody can read them back, and they never show
in the code or the logs.

From a machine that can reach the droplet over SSH, the same deploy is:

    INKWLL_SERVER=<droplet IP> bin/kamal setup     # the first time only
    INKWLL_SERVER=<droplet IP> bin/kamal deploy    # every time after

## Browser checks never touch the live game

**Actions → Probe login** tries signing up and logging in with real Firefox and
Chromium browsers. It does this on a throwaway copy of the game started inside
the run (its own empty database), with a new random password every time, and
it all disappears when the run ends. The scripts are in `script/probe/` and
refuse to run against anything but `127.0.0.1`. Tests in `test/lib/` fail if a
workflow that signs players up uses the live game's address, or if a password
is written into a workflow or script.

Never test sign-up on the live game: every account made there stays. An
earlier version did, with a shared password, and left "Probe" players and a
forum thread behind. To find and clear them, run **Actions → Clean up probe
players** first with "Clean up" unticked (lists them), then ticked (removes
them completely: their forum threads and posts, OOC messages, Messages, Passages,
characters and the account itself). It only matches names like `Probe1760000000000` with an
`@example.com` email.

## Content Security Policy

The game sends a Content Security Policy (`config/initializers/content_security_policy.rb`):
scripts only from the game itself (the import map carries a nonce), no plug-ins,
no framing by other sites, live updates only back to the game. Pictures may come
from any https site, because forum and wiki posts can show pictures. Styles may
be inline. If a new feature adds an inline `<script>`, an outside script or font,
or a connection to another site, the browser will block it and the console will
say "Content Security Policy"; add the site to that file deliberately.

## Still to do

- A mail service: its details go in `deploy/secrets.env` as SMTP_ADDRESS,
  SMTP_PORT, SMTP_USERNAME and SMTP_PASSWORD. Until then no emails are sent.
- The nightly database backup to DigitalOcean Spaces (see `docs/decisions.md`).
