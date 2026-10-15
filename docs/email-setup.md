# Setting up email with Brevo

The game already knows how to send email. It only needs Brevo's details. Do this once.

## 1. Brevo account

1. Sign up at brevo.com (free plan: 300 emails a day).
2. Settings > Senders, Domains & Dedicated IPs > Domains > Add a domain: `inkwll.com`.
3. Brevo shows records to add at Namecheap (Domain List > Manage > Advanced DNS). Add the **DKIM** record(s) and the **Brevo code** TXT record exactly as shown.

## 2. SPF: merge, don't add a second one

Namecheap already has one SPF TXT record on `@`:

    v=spf1 include:spf.efwd.registrar-servers.com ~all

A domain may only have one SPF record. Edit that record to add Brevo's include before `~all`:

    v=spf1 include:spf.efwd.registrar-servers.com include:spf.brevo.com ~all

(If Brevo shows a different include, use the one Brevo shows.) Optionally add a DMARC TXT record on `_dmarc`: `v=DMARC1; p=none; rua=mailto:you@inkwll.com`.

## 3. SMTP key

In Brevo: SMTP & API > SMTP. Note the login and create an SMTP key.

## 4. Give the details to the deploy (never in git)

Add these as GitHub Actions secrets (Settings > Secrets and variables > Actions), and tell Claude when they're in: the deploy settings (`config/deploy.yml`, `.kamal/secrets`, the Deploy workflow) still need a small change to pass them to the game, and that change should go out together with the secrets so a deploy never breaks on a missing one.

    SMTP_ADDRESS=smtp-relay.brevo.com
    SMTP_PORT=587
    SMTP_USERNAME=<the Brevo SMTP login>
    SMTP_PASSWORD=<the SMTP key>

    MAIL_FROM=Inkwll <no-reply@inkwll.com>

`MAIL_FROM` is the "from" address on the game's emails; keep it on `inkwll.com` so it matches the verified domain.

## 5. Deploy and test

After the next deploy, use "Forgot password" on a test account and check the email arrives (and not in spam).
