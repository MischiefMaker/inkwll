import { Controller } from "@hotwired/stimulus"

// Highlights the tab for the Chapter on screen, and hides its unread count,
// since the player is reading it. The bar can fold away to just its title
// (remembered in this browser); it tells the page how tall it is so the OOC
// Chat can leave room for it.
export default class extends Controller {
  static targets = ["tab", "toggle"]

  connect() {
    this.apply(this.stored())
    this.observer = new ResizeObserver(() => this.publishHeight())
    this.observer.observe(this.element)
  }

  disconnect() {
    this.observer?.disconnect()
    document.documentElement.style.setProperty("--tabs-height", "0px")
  }

  tabTargetConnected(tab) {
    const current = window.location.pathname === new URL(tab.href).pathname
    tab.classList.toggle("chapter-tab--current", current)
    if (current) tab.setAttribute("aria-current", "page")
  }

  toggle() {
    const collapsed = !this.element.classList.contains("chapter-tabs--collapsed")
    try { localStorage.setItem("chapterTabsCollapsed", collapsed ? "1" : "0") } catch (e) { /* remembering is optional */ }
    this.apply(collapsed)
  }

  apply(collapsed) {
    this.element.classList.toggle("chapter-tabs--collapsed", collapsed)
    if (this.hasToggleTarget) this.toggleTarget.setAttribute("aria-expanded", String(!collapsed))
    this.publishHeight()
  }

  stored() {
    try { return localStorage.getItem("chapterTabsCollapsed") === "1" } catch (e) { return false }
  }

  publishHeight() {
    document.documentElement.style.setProperty("--tabs-height", `${this.element.offsetHeight}px`)
  }
}
