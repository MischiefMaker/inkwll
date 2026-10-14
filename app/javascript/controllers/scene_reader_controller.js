import { Controller } from "@hotwired/stimulus"

// Tells the server how far the player has read in this Chapter, but only
// while the page is actually visible, so Passages that arrive while they're
// in another tab stay unread.
export default class extends Controller {
  static targets = ["passages"]
  static values = { url: String, participating: Boolean }

  connect() {
    this.sent = 0
    this.report = this.report.bind(this)
    document.addEventListener("visibilitychange", this.report)
    if (this.hasPassagesTarget) {
      this.observer = new MutationObserver(this.report)
      this.observer.observe(this.passagesTarget, { childList: true })
    }
    this.report()
  }

  disconnect() {
    document.removeEventListener("visibilitychange", this.report)
    this.observer?.disconnect()
  }

  report() {
    if (!this.participatingValue || !this.hasPassagesTarget || document.visibilityState !== "visible") return

    const sequences = Array.from(this.passagesTarget.querySelectorAll("[data-sequence]"), el => Number(el.dataset.sequence))
    const upTo = Math.max(0, ...sequences)
    if (upTo <= this.sent) return

    this.sent = upTo
    const token = document.querySelector("meta[name='csrf-token']")?.content
    fetch(this.urlValue, {
      method: "PATCH",
      headers: { "Content-Type": "application/json", "X-CSRF-Token": token },
      body: JSON.stringify({ up_to: upTo })
    })
  }
}
