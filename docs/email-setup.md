# Setting up email with Brevo

The game sends password resets and notification emails through Brevo (free for 300 emails a day). The game and the deploy are already wired up: they only need your Brevo login and key. Until those are in, the game quietly sends no email.

You do this once. It takes four stops: Brevo, DigitalOcean, Brevo again, GitHub. Then Claude deploys and you test.

Every Well on your droplet (inkwll.com, wild.inkwll.com and any new ones) shares this one Brevo account. Their emails all come from `no-reply@inkwll.com`, with each game's own name as the sender name, for example "Last Call of the Wild".

## 1. Make a Brevo account

1. Go to brevo.com and click **Sign up free**. Use your own email address.
2. Fill in the questions it asks (company name can be "Inkwll"; pick the free plan).
3. Confirm your email address from the message Brevo sends you.

## 2. Tell Brevo about inkwll.com

1. In Brevo, click your name or the cog at the top right, then **Senders, Domains & Dedicated IPs**.
2. Open the **Domains** tab and click **Add a domain**. Type `inkwll.com`.
3. If Brevo offers to set it up automatically by signing in to your domain provider, skip that and choose to add the records yourself.
4. Brevo now shows a short list of DNS records, usually:
   - a **TXT** record holding `brevo-code:` and a long code,
   - one or two **CNAME** records whose names start with `brevo1._domainkey` and `brevo2._domainkey` (this is DKIM, which proves the emails really come from you),
   - a **DMARC** TXT record on `_dmarc`.

   Leave this page open. You copy each record into DigitalOcean next.

## 3. Add the records in DigitalOcean

inkwll.com's records now live at DigitalOcean, not Namecheap (it was moved on 2026-10-16 so new Wells get their addresses automatically). Don't add anything at Namecheap: it's ignored.

1. Log in to cloud.digitalocean.com. In the left menu click **Networking**, then the **Domains** tab, then **inkwll.com**.
2. At the top is a row of record types (A, AAAA, CNAME, MX, TXT…). For each record Brevo shows, click its type, fill in the boxes, and click **Create Record**:

   | Brevo record | Type tab | Hostname box | Value box |
   | --- | --- | --- | --- |
   | Brevo code | TXT | `@` | the whole `brevo-code:…` text |
   | DKIM 1 | CNAME | `brevo1._domainkey` | what Brevo shows, e.g. `b1.inkwll-com.dkim.brevo.com` |
   | DKIM 2 | CNAME | `brevo2._domainkey` | what Brevo shows |
   | DMARC | TXT | `_dmarc` | what Brevo shows, or `v=DMARC1; p=none` |
   | SPF | TXT | `@` | `v=spf1 include:spf.brevo.com ~all` (only if Brevo lists an SPF record) |

   Two things trip people up:
   - **Hostname:** if Brevo shows a full name such as `brevo1._domainkey.inkwll.com`, type only the part before `.inkwll.com`. DigitalOcean adds `.inkwll.com` itself. For records Brevo shows on the domain itself (`inkwll.com`), type `@`.
   - **Values:** copy them exactly. Leave TTL as it is.

   There is no SPF record yet (the old Namecheap one didn't come over and isn't needed), so the SPF row is a new record, and a domain only ever has one. If you add more email services later, they go into that same record.
3. Go back to the Brevo page from step 2 and click **Authenticate this email domain** (or **Verify**). DigitalOcean is quick, but if Brevo says it can't see the records yet, wait 15 minutes and try again. When it works, inkwll.com shows as **Authenticated**.

## 4. Add the sender address in Brevo

1. Still in **Senders, Domains & Dedicated IPs**, open the **Senders** tab and click **Add a sender**.
2. From name: `Inkwll`. From email: `no-reply@inkwll.com`. Save.

Because the domain is authenticated, Brevo should accept it straight away. If it asks you to confirm by clicking a link in an email, tell Claude: nothing receives mail at inkwll.com yet, so we'd sort that out another way.

## 5. Get the SMTP login and key

1. Click your name or the cog at the top right, then **SMTP & API**, and open the **SMTP** tab.
2. Note the **Login** shown there. It looks like `8a1b2c001@smtp-brevo.com`. This is the SMTP username (it is not your own email address).
3. Click **Generate a new SMTP key**, name it `Inkwll`, and copy the key. Brevo only shows it once; if you lose it, make a new one.

If Brevo says your SMTP account isn't activated yet, it reviews new accounts first. Fill in what it asks for, or contact Brevo support; it's usually quick.

## 6. Put them in GitHub (never in git or chat)

1. Open github.com/MischiefMaker/inkwll, then **Settings** (top row) > **Secrets and variables** (left) > **Actions**.
2. Click **New repository secret** and add these two, one at a time:

   | Name | Secret |
   | --- | --- |
   | `SMTP_USERNAME` | the Login from step 5, e.g. `8a1b2c001@smtp-brevo.com` |
   | `SMTP_PASSWORD` | the SMTP key from step 5 |

   The names must be exactly as written, in capitals.

You don't need to set the server address, port or "from" address: the game already uses `smtp-relay.brevo.com`, port 587 and `no-reply@inkwll.com`.

## 7. Deploy and test

1. Tell Claude the secrets are in and say "Deploy". Email starts working with the next deploy of each Well (inkwll.com first; other Wells pick it up on their next Update).
2. Log out, click **Forgot password**, and enter an account that has your email address on it.
3. The email should arrive within a minute from "Inkwll <no-reply@inkwll.com>". Check your spam folder too. If it's in spam, mark it "Not spam" and tell Claude.

In Brevo, **Transactional** > **Logs** (or **Statistics**) shows every email the game sent and whether it was delivered, which helps if one goes missing.

## For other mail services

The game works with any SMTP service. Set `SMTP_ADDRESS` and `SMTP_PORT` as well (in `config/deploy.yml` and `.kamal/secrets`), and change `MAIL_FROM_ADDRESS` in `config/deploy.yml` to an address on the domain that service has verified. `MAIL_FROM` replaces the whole "from" line if set.
