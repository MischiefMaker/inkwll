# Handing work to another AI

Claude does most of the work on Inkwll. When you want ChatGPT or another free AI to take a smaller job, this is the round trip.

## Good jobs to hand off

Work that fits on one page and does not need the whole codebase:

- Writing help text, error messages, or page copy
- Sample data: rooms, descriptions, test characters
- CSS and HTML for a single page or component
- A first draft of one small, well-described Ruby method
- Researching a question and summarizing the answer

Keep for Claude: anything that touches several files, the database, logins or permissions, or that needs a decision from you.

## The round trip

1. **Pick or make a task.** Ask Claude to "prep a handoff task for X", or copy `tasks/TEMPLATE.md` yourself. Set its **Hand off?** line to `Yes`. The task must contain everything the other AI needs, because it cannot see this repository.
2. **Send it.** Open ChatGPT (or another AI). Paste the starter message below, then paste the whole task file.
3. **Bring the answer back.** Create a file in `tasks/inbox/` named after the task, for example `tasks/inbox/0001-visibility-help-text.md`, and paste the AI's full reply into it. On GitHub you can do this with **Add file > Create new file**. Or just paste the reply into a chat with Claude.
4. **Mark it.** Change the task's **Status** to `Review`.
5. **Claude checks it.** Claude reviews the answer, tests it, applies what holds up, and marks the task `Done` (or back to `Open` with notes on what was missing).

## Starter message

Paste this before the task file:

```
You are helping build Inkwll, a web-based roleplaying game made with
Ruby on Rails 8, Hotwire (Turbo and Stimulus) and PostgreSQL.

Rules:
- Do only the task below. Do not add features or change anything it does
  not mention.
- Do not invent Rails or library features. If you are unsure something
  exists, say so.
- If anything is unclear, put your questions at the very top of your reply
  instead of guessing.
- Give complete file contents, not snippets, and start each file with its
  path on its own line, like: FILE: app/views/rooms/show.html.erb
- Finish with a short plain-language summary of what you did.

Here is the task:
```
