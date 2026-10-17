import { Controller } from "@hotwired/stimulus"

// Keeps what a player is writing as a draft in this browser while they type,
// so nothing is lost if the page closes or reloads. Posting clears it.
//
// An empty box gets its draft back on its own. A box that already has text
// (editing a wiki page, say) offers the draft instead: "Use it" or
// "Throw it away". Drafts are kept for two weeks, per player and per box.
export default class extends Controller {
  static targets = ["field"]
  static values = { key: String }
  static KEEP_FOR = 14 * 24 * 60 * 60 * 1000

  connect() {
    if (!this.hasFieldTarget || !this.storage) return
    this.forget_old()
    const draft = this.read()
    if (!draft || draft.text === this.fieldTarget.value) return
    if (this.fieldTarget.value.trim() === "") {
      this.fieldTarget.value = draft.text
      this.note("Your unposted draft was kept.", false)
    } else {
      this.note("You have an unposted draft from earlier.", true, draft.text)
    }
  }

  disconnect() {
    clearTimeout(this.timer)
  }

  // Saves a moment after typing stops.
  save() {
    clearTimeout(this.timer)
    this.timer = setTimeout(() => {
      const text = this.fieldTarget.value
      if (text.trim() === "") this.clear()
      else this.write({ text, savedAt: Date.now() })
    }, 400)
  }

  posted(event) {
    if (event.detail.success) {
      clearTimeout(this.timer)
      this.clear()
      this.element.querySelector(".draft-note")?.remove()
    }
  }

  // --- The note above the box ----------------------------------------------

  note(text, offer, draftText) {
    const note = document.createElement("p")
    note.className = "draft-note hint"
    note.append(text + " ")
    if (offer) {
      note.append(this.button("Use it", "draft-note__use", () => { this.fieldTarget.value = draftText; note.remove() }))
      note.append(" ")
    }
    note.append(this.button(offer ? "Throw it away" : "Clear", "draft-note__discard", () => {
      if (!offer) this.fieldTarget.value = ""
      this.clear()
      note.remove()
    }))
    this.fieldTarget.before(note)
  }

  button(label, className, action) {
    const button = document.createElement("button")
    button.type = "button"
    button.className = `button-link ${className}`
    button.textContent = label
    button.addEventListener("click", action)
    return button
  }

  // --- Storage -------------------------------------------------------------

  get storage() {
    try { return window.localStorage } catch { return null }
  }

  get storageKey() {
    const account = document.querySelector("meta[name=inkwll-account]")?.content || "guest"
    return `inkwll-draft:${account}:${this.keyValue}`
  }

  read() {
    try { return JSON.parse(this.storage.getItem(this.storageKey)) } catch { return null }
  }

  write(draft) {
    try { this.storage.setItem(this.storageKey, JSON.stringify(draft)) } catch { /* storage full or blocked */ }
  }

  clear() {
    try { this.storage.removeItem(this.storageKey) } catch { /* blocked */ }
  }

  forget_old() {
    const cutoff = Date.now() - this.constructor.KEEP_FOR
    try {
      for (let i = this.storage.length - 1; i >= 0; i--) {
        const key = this.storage.key(i)
        if (!key?.startsWith("inkwll-draft:")) continue
        const savedAt = JSON.parse(this.storage.getItem(key))?.savedAt || 0
        if (savedAt < cutoff) this.storage.removeItem(key)
      }
    } catch { /* blocked or malformed */ }
  }
}
