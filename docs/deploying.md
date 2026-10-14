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
- Until the game has a domain name, it runs on the droplet's IP address over
  plain http (`INKWLL_HTTPS: "false"` in `config/deploy.yml`). Passwords are
  not encrypted on the way, so only invite testers until there's a domain.

## Deploying

From the cloud environment, with the droplet's IP address:

    INKWLL_SERVER=<droplet IP> kamal setup     # the first time only
    INKWLL_SERVER=<droplet IP> kamal deploy    # every time after

Claude asks the owner before each deploy goes live.

## Still to do

- A domain name, then HTTPS (see the comments in `config/deploy.yml`).
- A mail service: its details go in `deploy/secrets.env` as SMTP_ADDRESS,
  SMTP_PORT, SMTP_USERNAME and SMTP_PASSWORD. Until then no emails are sent.
- The nightly database backup to DigitalOcean Spaces (see `docs/decisions.md`).
