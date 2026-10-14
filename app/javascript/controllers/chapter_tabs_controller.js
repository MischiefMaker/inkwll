import { Controller } from "@hotwired/stimulus"

// Highlights the tab for the Chapter on screen, and hides its unread count,
// since the player is reading it.
export default class extends Controller {
  static targets = ["tab"]

  tabTargetConnected(tab) {
    const current = window.location.pathname === new URL(tab.href).pathname
    tab.classList.toggle("chapter-tab--current", current)
    if (current) tab.setAttribute("aria-current", "page")
  }
}
