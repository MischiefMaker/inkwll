import { Controller } from "@hotwired/stimulus"

// Keeps the newest Passages in view: opens at the bottom of the Chapter, and
// follows new Passages as they arrive, unless the player has scrolled up to
// read something earlier. A live Chapter scrolls inside its own box
// (.passages--scroll); any other page scrolls the whole window.
export default class extends Controller {
  connect() {
    this.atBottom = true
    this.boxed = this.element.classList.contains("passages--scroll")
    this.scroller = this.boxed ? this.element : window
    this.track = () => {
      this.atBottom = this.boxed
        ? this.element.scrollHeight - this.element.scrollTop - this.element.clientHeight < 80
        : window.innerHeight + window.scrollY >= document.body.scrollHeight - 200
    }
    this.scroller.addEventListener("scroll", this.track, { passive: true })
    this.observer = new MutationObserver(() => { if (this.atBottom) this.scrollDown() })
    this.observer.observe(this.element, { childList: true })
    if (this.boxed || !window.location.hash) this.scrollDown()
  }

  disconnect() {
    this.scroller.removeEventListener("scroll", this.track)
    this.observer.disconnect()
  }

  scrollDown() {
    if (this.boxed) {
      this.element.scrollTop = this.element.scrollHeight
    } else {
      window.scrollTo(0, document.body.scrollHeight)
    }
  }
}
