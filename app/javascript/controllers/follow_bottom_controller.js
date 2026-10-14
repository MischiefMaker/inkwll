import { Controller } from "@hotwired/stimulus"

// Keeps the newest Passages in view: opens at the bottom of the Chapter, and
// follows new Passages as they arrive, unless the player has scrolled up to
// read something earlier.
export default class extends Controller {
  connect() {
    this.atBottom = true
    this.track = () => { this.atBottom = window.innerHeight + window.scrollY >= document.body.scrollHeight - 200 }
    window.addEventListener("scroll", this.track, { passive: true })
    this.observer = new MutationObserver(() => { if (this.atBottom) this.scrollDown() })
    this.observer.observe(this.element, { childList: true })
    if (!window.location.hash) this.scrollDown()
  }

  disconnect() {
    window.removeEventListener("scroll", this.track)
    this.observer.disconnect()
  }

  scrollDown() {
    window.scrollTo(0, document.body.scrollHeight)
  }
}
