# 0001: Help text for private and hidden scenes

- **Status:** Done
- **Hand off?:** Yes
- **Roadmap step:** 3. Logs and safety
- **Created:** 2026-10-14

## Goal

Short, friendly UI text that tells players who can see a scene, and that staff can read it if it is reported.

## Background

Inkwll is a web roleplaying game. A "scene" is a live chat inside a room. Each scene has one of three visibility settings:

- **Joinable** (default): anyone in the room can see it and join.
- **Private:** others can see that it exists and who is in it, but cannot join without an invite. When it ends, its log is shown on the room and on each character's page.
- **Hidden:** only its players can see it. When it ends, the log is visible only to its players, unless every player agrees to make it public. Hidden always means private too.

Moderation rule (must be stated clearly): staff cannot browse private or hidden scenes. If someone reports one, staff can read that one scene's log, and nothing else.

The game has no fixed setting or genre, so keep the text neutral.

## What to do

1. Write a one-line description for each of the three settings, shown next to the option when someone creates a scene.
2. Write a short notice (two sentences at most) shown when a scene is set to private or hidden, explaining that staff can read it if it is reported.
3. Write a short notice for the top of the report form explaining that staff will be able to read the reported scene's log.

## Do not

- Write any code or HTML. Plain text only.
- Promise anything the rules above do not say.

## What to send back

A plain list with headings: "Joinable", "Private", "Hidden", "Private or hidden notice", "Report form notice". Then one or two alternative wordings for the two notices.

## Done when

- [ ] Each piece is one or two sentences and readable by a new player
- [ ] Both notices clearly say staff can read a scene only after a report
- [ ] The owner has picked the wording

## Notes

2026-10-17: Done without a hand-off. Claude wrote the wording while building Chapters: the "Who can join" choices on the new Chapter form (`app/views/scenes/_list.html.erb`) describe each setting, and the report form (`app/views/scenes/reports/new.html.erb`) says staff can read a reported Chapter but not unreported private or hidden ones. It is live on inkwll.com.
