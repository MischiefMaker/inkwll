import { Controller } from "@hotwired/stimulus"

// The admin menu starts open. On a phone-sized screen it folds into
// one "Admin menu" button at the top of the page instead.
//
// On a wide screen the menu is as tall as the space left on screen below its
// real position (under the header and the Chapter tabs), and it sticks at the
// top as you scroll, so its last link is always reachable.
export default class extends Controller {
  connect() {
    this.phone = window.matchMedia("(max-width: 800px)")
    if (this.phone.matches) this.element.open = false
    this.resize = () => {
      if (this.frame) return
      this.frame = requestAnimationFrame(() => { this.frame = null; this.fit() })
    }
    window.addEventListener("scroll", this.resize, { passive: true })
    window.addEventListener("resize", this.resize)
    this.observer = new ResizeObserver(this.resize)
    this.observer.observe(document.body)
    this.fit()
  }

  disconnect() {
    window.removeEventListener("scroll", this.resize)
    window.removeEventListener("resize", this.resize)
    this.observer?.disconnect()
    if (this.frame) cancelAnimationFrame(this.frame)
  }

  fit() {
    if (this.phone.matches) {
      this.element.style.removeProperty("--admin-menu-height")
      return
    }
    const top = Math.max(0, this.element.getBoundingClientRect().top)
    this.element.style.setProperty("--admin-menu-height", `${Math.max(160, window.innerHeight - top)}px`)
  }
}
