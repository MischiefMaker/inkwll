import { Controller } from "@hotwired/stimulus"

// The box for writing a Passage. Warns before posting out of turn, clears
// itself after posting, and posts on Ctrl+Enter (Cmd+Enter on a Mac). In a
// live-chat Chapter plain Enter posts, and Shift+Enter starts a new line.
// Players can also post as an NPC, narration or an OOC line; only Passages
// and NPC Passages take a turn.
export default class extends Controller {
  static targets = ["body", "anyway", "warning", "warningText", "kind", "npc", "npcName", "label", "mutter", "mutterTo", "letter", "npcPick"]
  static values = { enterPosts: Boolean }

  get kind() {
    return this.kindTargets.find(input => input.checked)?.value || "passage"
  }

  kindChanged() {
    const npc = this.kind === "npc"
    this.npcTarget.hidden = !npc
    const picked = this.hasNpcPickTarget && this.npcPickTarget.value !== ""
    this.npcNameTarget.required = npc && !picked
    this.npcNameTarget.disabled = picked
    if (this.hasMutterTarget) this.mutterTarget.hidden = this.kind !== "mutter"
    this.letterTarget.hidden = this.kind !== "letter"
    this.labelTarget.textContent = this.labelTarget.dataset[this.kind]
    this.element.closest(".composer").dataset.kind = this.kind
    if (!["passage", "npc"].includes(this.kind)) this.cancel()
  }

  // Whose turn it is comes from the turn bar, which updates live.
  check(event) {
    const turnBar = document.getElementById("turn-bar")
    if (!["passage", "npc"].includes(this.kind)) return
    if (this.anywayTarget.value === "1" || turnBar?.dataset.outOfTurn !== "true") return

    event.preventDefault()
    this.warningTextTarget.textContent = `It's ${turnBar.dataset.turnName}'s turn.`
    this.warningTarget.hidden = false
  }

  postAnyway() {
    this.anywayTarget.value = "1"
    this.warningTarget.hidden = true
    this.element.requestSubmit()
  }

  cancel() {
    this.warningTarget.hidden = true
  }

  reset(event) {
    this.anywayTarget.value = "0"
    if (event.detail.success) {
      this.bodyTarget.value = ""
      // Back to an ordinary Passage after an OOC line or narration.
      if (["ooc", "narration", "mutter", "letter"].includes(this.kind)) {
        this.kindTargets.find(input => input.value === "passage").checked = true
        this.kindChanged()
      }
    }
  }

  shortcut(event) {
    if (event.key !== "Enter" || event.isComposing) return
    const plainEnter = this.enterPostsValue && !event.shiftKey && !event.altKey && event.target === this.bodyTarget
    if (event.ctrlKey || event.metaKey || plainEnter) {
      event.preventDefault()
      this.element.requestSubmit()
    }
  }
}
