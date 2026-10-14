import { Controller } from "@hotwired/stimulus"

// Folds the OOC chat into the right edge and brings it back out.
// Remembers the choice in this browser.
export default class extends Controller {
  static targets = ["toggle"]

  connect() {
    this.apply(this.stored() === "collapsed")
  }

  toggle() {
    const collapsed = !this.element.classList.contains("ooc-sidebar--collapsed")
    this.apply(collapsed)
    try { localStorage.setItem("ooc-sidebar", collapsed ? "collapsed" : "open") } catch {}
  }

  apply(collapsed) {
    this.element.classList.toggle("ooc-sidebar--collapsed", collapsed)
    this.toggleTarget.setAttribute("aria-expanded", String(!collapsed))
    this.toggleTarget.title = collapsed ? "Show OOC chat" : "Hide OOC chat"
  }

  stored() {
    try { return localStorage.getItem("ooc-sidebar") } catch { return null }
  }
}
