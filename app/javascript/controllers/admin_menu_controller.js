import { Controller } from "@hotwired/stimulus"

// The admin menu starts open. On a phone-sized screen it folds into
// one "Admin menu" button at the top of the page instead.
//
// On a wide screen the menu is as tall as the space on screen below the header
// and Chapter tabs when the page is at the top. That height stays fixed as you
// scroll, and the menu sticks at the top of the screen (like the OOC Chat), so
// its last link is always reachable and it never grows or shrinks.
export default class extends Controller {
  connect() {
    this.phone = window.matchMedia("(max-width: 800px)")
    if (this.phone.matches) this.element.open = false
    this.resize = () => {
      if (this.frame) return
      this.frame = requestAnimationFrame(() => { this.frame = null; this.fit() })
    }
    window.addEventListener("resize", this.resize)
    this.observer = new ResizeObserver(this.resize)
    this.observer.observe(document.body)
    this.fit()
  }

  disconnect() {
    window.removeEventListener("resize", this.resize)
    this.observer?.disconnect()
    if (this.frame) cancelAnimationFrame(this.frame)
  }

  fit() {
    if (this.phone.matches) {
      this.element.style.removeProperty("--admin-menu-height")
      return
    }
    // Where the menu sits on the page when scrolled to the top: the top of the
    // row it lives in, which doesn't move when the menu itself sticks.
    const top = Math.max(0, this.element.parentElement.getBoundingClientRect().top + window.scrollY)
    this.element.style.setProperty("--admin-menu-height", `${Math.max(160, window.innerHeight - top)}px`)
  }
}
