# Wells: launching and updating games

Decided by the owner on 2026-10-15 (see `decisions.md`). Step 12a is built; 12b to 12d are next.

## How updates work now (step 12a)

- **Admin → Wells** is only for the Founder. It shows this Well's version and the versions marked ready, newest first, each with its notes. "Update to" and "Go back to" buttons ask GitHub to run the Deploy workflow with that version. The page refreshes itself while an update runs and links to the log.
- **One update at a time.** The page refuses a second one while one is running, and refuses any version that isn't marked ready.
- **Backups:** the Deploy workflow dumps the database to `/root/backups` on the droplet before every deploy (except the first), keeps the newest ten, and stops if the dump fails. The off-server nightly copy to DigitalOcean Spaces is still to do (see `deploying.md`).
- **Going back** rebuilds the earlier version. Database changes made by newer versions stay, so a version's notes say when going back past it is unsafe.
- **The key:** the game reads `WELLS_GITHUB_TOKEN` (a fine-grained GitHub token, only the inkwll repository, Actions read and write, Contents read-only). It's a repository secret, and the Deploy workflow hands it to the game through Kamal. Without it, the page shows how to make one. `WELLS_GITHUB_REPO` and `WELLS_GITHUB_BRANCH` change where it points, for someone running their own copy.

### Marking a version ready (Claude)

When a commit on main has passed the tests and run on inkwll.com, Claude runs **Actions → Mark version ready** with the version name (v1.0, v1.1 and so on), the commit, and a few plain lines on what changed, saying if going back past it is unsafe. The workflow makes a GitHub Release (and its tag), and the Wells page lists it. Claude's cloud environment can't push tags directly, which is why this goes through a workflow.

---

The original proposal, as agreed:

## What the owner asked for

- A Founder-only page in Admin with buttons to start a new Well, either on the same droplet as inkwll.com or on a new droplet.
- Each Well can live at a subdomain (like `moonfall.inkwll.com`) or at its own domain (like `moonfall.com`).
- A way to update Wells to the newest Inkwll without asking Claude to deploy each time.

All of this fits the decision already made: one install per game, each with its own database and settings, and your games can share a droplet.

## How it would look

A new **Admin → Wells** page that only Founders can see. It lists every Well:

| Well | Address | Server | Version | |
|---|---|---|---|---|
| Inkwll | inkwll.com | Droplet 1 | v1.4 | Update |
| Moonfall | moonfall.inkwll.com | Droplet 1 | v1.3 | Update |
| Briarwood | briarwood.com | Droplet 2 | v1.4 | Update |

Buttons:

- **New Well**: a short form with the Well's name, the address (a subdomain, or a domain you own), and where it goes (this droplet or a new one). You type the Well's name again to confirm.
- **Update** on each row, and **Update all** at the top.
- **Progress**: each job shows "Working", "Done" or "Failed", with a link to the full log.
- When a new Well is ready, the page shows a one-time link to set up that Well's Founder account, so you are the first person in.

There is deliberately **no delete button**. Taking a Well down or destroying a droplet stays something you do by hand in DigitalOcean, the same rule we use for the old MUSH droplets.

## The big choice: who does the work when you press a button

### Option A (recommended): the button asks GitHub to do it

The Wells page sends a request to GitHub, and a GitHub Actions workflow does the real work: creating the droplet, setting up the database, and running Kamal. This is the same way deploys already happen today.

- The game itself only holds one small key, which is allowed to say "run this workflow" and nothing else.
- The powerful keys (the SSH key that can log into droplets, and the DigitalOcean key that can create droplets) stay in GitHub's locked secret store and never sit on a game server.
- Every run leaves a full log in GitHub, so if something goes wrong Claude can read exactly what happened.
- It works the same for the same droplet and for a new droplet.

### Option B: the game server runs Kamal itself

The game would need Docker control and SSH keys to every droplet inside it. If anyone ever broke into one game, they could reach every Well and your DigitalOcean account. It is also harder to debug. **Not recommended.**

## Keys and secrets it needs

| Secret | Where it lives | What it can do | Who makes it |
|---|---|---|---|
| GitHub "run workflows" token | inkwll.com's Kamal secrets | Start workflows in the inkwll repo only. It cannot read or change code. | You, in GitHub settings (Claude gives click-by-click steps) |
| DigitalOcean API token | GitHub secret | Create droplets and DNS records | You, in DigitalOcean (limited to droplets + domains) |
| Deploy SSH key | Already a GitHub secret | Log into droplets to install Wells | Already exists |
| Each Well's own passwords (database, app key) | On that Well's own server | Run that one Well | Made automatically when the Well is created |

Safety catches on the workflow: it refuses names it doesn't expect, it won't create more than a set number of droplets (so a leaked key can't run up a big bill), and the GitHub token expires after a year so it gets renewed on purpose.

## Same droplet or a new droplet

**Same droplet.** Kamal can run several apps side by side behind one front door, which sorts visitors by address. Each Well gets its own app and its own database, so nothing is shared except the machine. Cost is free, but memory is the limit. The $6 droplet has 1 GB and already needed swap for one Well. My estimate (inferred, not measured) is that it holds two small Wells at most. Moving to the **$12, 2 GB droplet** would fit three or four comfortably. Resizing a droplet takes a few minutes of downtime and is done in DigitalOcean.

**New droplet.** The workflow creates a fresh $6 droplet (plus about $1.20 a month for backups), adds swap, turns backups on, installs the Well, and sets up the nightly database backup. Each Well is fully separate, so one busy game can't slow another. This is best for a Well that someone else runs or that might grow.

## Addresses: subdomain or own domain

**Subdomains of inkwll.com (recommended default).** To create `moonfall.inkwll.com` automatically, the workflow has to add a DNS record. Namecheap's API is only open to accounts with 20+ domains or $50 of spending, so the simplest route is to **move inkwll.com's DNS to DigitalOcean**. The domain stays registered and paid for at Namecheap; you change one setting there (the nameservers) and DigitalOcean answers address lookups instead, which it does for free. Claude would copy over your existing records first (the site, www, and the email ones), so nothing breaks. After that the workflow can add a subdomain record for each new Well, on any droplet.

**A Well's own domain.** Nobody can automate DNS at a registrar we don't control, so this is a two-step thing:
1. Start the Well on a subdomain so it works right away.
2. Whoever owns the domain points it at the droplet's address (the Wells page shows the exact record to add). Then press **Add domain**, and the page checks it and switches HTTPS on once it resolves.

HTTPS certificates are free and automatic either way (the same Let's Encrypt setup inkwll.com uses now).

## Updating without Claude

The **Update** button deploys a chosen version of Inkwll to that Well. The risk to weigh: whatever version you push goes live for real, without anyone checking it first. A bad change could break a game, and changes to the database (adding columns and so on) can't always be undone by going back a version.

The proposal to keep that safe:

1. **Updates use "ready" versions only, not whatever is newest.** Claude keeps working on main as now. When a batch of changes passes the tests and has been live on inkwll.com for a while, Claude marks it as a numbered version (v1.5, and so on) with a plain-language list of what changed. The Wells page only offers marked versions.
2. **inkwll.com goes first.** Update all does inkwll.com, then the others one at a time, and stops if one fails.
3. **A database backup before every update**, saved off the server.
4. **A "Go back" button** that returns a Well to its previous version if an update misbehaves (with the database caveat above, which the version notes would flag).

This still keeps the rule that you OK every deploy. Pressing the button *is* your OK. Claude would stop deploying to Wells other than inkwll.com unless you ask.

## Building it in steps

Each step is usable on its own, and each needs your go-ahead.

1. **Wells page + Update for inkwll.com itself.** Versions, the backup-before-update, Go back. This replaces asking in chat for deploys.
2. **New Well on the same droplet, at a subdomain.** Needs the DNS move and probably the 2 GB droplet.
3. **New Well on a new droplet.** Needs the DigitalOcean token.
4. **Own domains** for Wells.
