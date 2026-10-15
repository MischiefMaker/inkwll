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

## Still to do

- A mail service: its details go in `deploy/secrets.env` as SMTP_ADDRESS,
  SMTP_PORT, SMTP_USERNAME and SMTP_PASSWORD. Until then no emails are sent.
- The nightly database backup to DigitalOcean Spaces (see `docs/decisions.md`).
