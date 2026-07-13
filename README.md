# Pedals of Hope

Static marketing / intake site for **Pedals of Hope**, a nonprofit that
connects children with disabilities to adaptive bikes.

## Live site

**https://kirkautomations.com/pedals-of-hope/**

Hosted on the Kirk Automations Hetzner box via Caddy static file serving.
(Future move: dedicated domain like `pedalsofhope.org`.)

## Structure

Plain static HTML/CSS/images. No build step, no framework.

```
index.html       Home
about.html       Who we are + staff
programs.html    What we fund
stories.html     Rider stories (per-rider sponsor buttons)
donate.html      Donation form (FormSubmit -> pedalsofhopeorg@gmail.com)
intake.html      Application form
contact.html     Contact / volunteer / partner form
thanks.html      Form-submit thank-you page
css/             Stylesheets
images/          Photos & assets
```

## Editing

Anyone on the Kirk-Automations org can edit:

1. `git clone git@github.com:Kirk-Automations/pedals-of-hope.git`
2. Edit HTML/CSS
3. `git commit && git push origin main`
4. `./deploy.sh` — pushes live in ~15 seconds

## Deploying

```bash
./deploy.sh
```

Requires:

- SSH access to `kirk-auto` (Hetzner prod box)
- sudo on that box

The script packages the tree, ships it via scp, atomically swaps
`/var/www/kirkautomations/pedals-of-hope` on prod, and verifies the
live URL returns 200.

## Forms

Currently all forms submit to **FormSubmit** targeting
`pedalsofhopeorg@gmail.com`. This is a placeholder — swap for a real
payment processor (Stripe / Donorbox / Zeffy / etc.) when ready.
