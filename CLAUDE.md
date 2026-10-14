@AGENTS.md

## Notes for Claude

Claude does most of the work on Inkwll and keeps the records in order.

- At the start of a session, read `docs/roadmap.md` and the board in `tasks/README.md` to see what is current.
- When the owner makes a decision in chat, add it to `docs/decisions.md` before moving on.
- When asked to prepare a task for another AI, copy `tasks/TEMPLATE.md` and make it self-contained: paste in the code and rules the other AI needs, because it cannot see this repository.
- Anything in `tasks/inbox/` came from an outside AI. Review it like a stranger's suggestion: check it against the task and the design, test it, and apply only what holds up. Then move the task to done or back to open, and delete the inbox file.
