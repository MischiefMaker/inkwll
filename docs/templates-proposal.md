# Templates beyond CSS: a proposal

**[Proposed]** Written by Claude on 2026-10-17 for the roadmap item "Templates beyond CSS" (Theme 7). Nothing here is built yet. The owner decides before any of it is.

## What Jcink does

Jcink's HTML Templates (https://jcink.com/wiki/jfh-html-templates) let an admin replace the HTML of twelve pieces of the board: category headers, subforum headers, forum rows, redirect rows, topic list headers, topic rows, board statistics, main profiles, member list headers and rows, mini profiles, and post rows.

- Each template is plain HTML with placeholders. Values are written as `<!-- |forum_id| -->`, and whole generated blocks as `<% TOPIC_ROWS %>`. A block is left out if its placeholder is missing.
- Admins make a template set under Admin CP » Skins and Templates » HTML Templates, then attach it to a skin. Only one set can be active at a time.
- Templates give full control, and you don't have to keep the default class names. Some features break if certain markup is missing: the `entry` anchor on a post row, for example, or Quick Edit's exact `div`.
- There's no safety net beyond downloading the default set. Jcink's page says nothing about sandboxing, checks, version history or a reset button.

## What Inkwll could do

Inkwll would take Jcink's idea of replacing small, repeated pieces rather than whole pages, and add the safety Jcink lacks.

1. **Which pieces.** Start with the pieces players see most and games most want to change:
   - a Passage in a Chapter
   - a character's mini-profile and the top of their profile
   - a row in a Chapter list
   - a forum post
   - an Area card on the front page

   Whole pages stay Inkwll's, so turns, live updates, drafts and forms keep working.
2. **The template language.** Templates would be written in Liquid, Shopify's template language for shops that customers edit themselves. It runs no Ruby or JavaScript, only the values we hand it, so a mistake or a bad actor can't reach the database. Liquid is a Ruby library inside the app and needs no extra hosting. A Passage template might read:
   ```
   <div class="passage">{{ character.icon }} <b>{{ character.name }}</b> {{ passage.body }}</div>
   ```
   Every value is escaped unless Inkwll already made it safe, such as the Passage body.
3. **Safety.** Every saved template is cleaned like a wiki page, with no `<script>`, no `on…=` attributes and no `javascript:` links. Inkwll also keeps the markup it needs, such as the hooks for live updates and editing, by wrapping each template in its own outer element.
4. **Editing.** The editor would be Admin → Look → Templates, for staff who change game settings. Each piece would have:
   - a box showing the default
   - a live preview with sample data
   - a history of versions, like wiki pages
   - a **Reset to default** button

   A template that fails to render falls back to the default, and staff see a notice.
5. **Theme packs.** Templates would travel with the look in the world export/import, so a Well can be launched with its templates.

## Questions for the owner

1. Which pieces should come first? Claude suggests the Passage and the mini-profile.
2. Should templates be Liquid as above, or only plain HTML with `<!-- |name| -->` placeholders like Jcink? Plain HTML is more familiar to Jcink skinners, but it can't do "if the character has an icon, show it".
3. Should only Wellkeepers edit templates, or also Scribes with the game settings job?

## Destroy a Well

The other Theme 7 item, destroying a Well with a restorable backup, waits on steps 12c and 12d, as the roadmap says. Those steps are live deploy work on `main` (new droplets and own domains). They can't be built or tried on the `v2.0` branch without deploying, so this item was not started.
