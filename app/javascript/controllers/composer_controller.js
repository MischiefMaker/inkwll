import { Controller } from "@hotwired/stimulus"

// The box for writing a Passage. Warns before posting out of turn, clears
// itself after posting, and posts on Ctrl+Enter (Cmd+Enter on a Mac).
export default class extends Controller {
  static targets = ["body", "anyway", "warning", "warningText"]

  // Whose turn it is comes from the turn bar, which updates live.
  check(event) {
    const turnBar = document.getElementById("turn-bar")
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
    if (event.detail.success) this.bodyTarget.value = ""
  }

  shortcut(event) {
    if (event.key === "Enter" && (event.ctrlKey || event.metaKey)) {
      event.preventDefault()
      this.element.requestSubmit()
    }
  }
}
