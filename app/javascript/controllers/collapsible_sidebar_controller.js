import { Controller } from "@hotwired/stimulus"

// Folds the OOC Chat into the right edge and brings it back out.
// While it's folded, the tab counts messages the player hasn't seen.
// Remembers both the choice and the last message seen in this browser.
// Admin pages fold it away on the way in, to make room for the admin
// menu, and put it back as it was on the way out.
// On a wide screen it is as tall as the space below the header and Chapter
// tabs (measured, not guessed), and sticks to the top as you scroll.

// Whether the last page shown was an admin page (null before the first page).
let onAdminPage = null

export default class extends Controller {
  static targets = ["toggle", "count", "messages"]

  connect() {
    this.followPage()
    this.pageChanged = () => { this.followPage(); this.fit() }
    document.addEventListener("turbo:load", this.pageChanged)
    this.phone = window.matchMedia("(max-width: 800px)")
    this.resize = () => {
      if (this.frame) return
      this.frame = requestAnimationFrame(() => { this.frame = null; this.fit() })
    }
    window.addEventListener("resize", this.resize)
    this.sizeObserver = new ResizeObserver(this.resize)
    this.sizeObserver.observe(document.body)
    this.fit()
    if (this.read("ooc-last-seen") === null) this.markSeen()
    this.refresh()
    this.observer = new MutationObserver(() => this.refresh())
    this.observer.observe(this.messagesTarget, { childList: true })
  }

  disconnect() {
    this.observer.disconnect()
    this.sizeObserver?.disconnect()
    window.removeEventListener("resize", this.resize)
    if (this.frame) cancelAnimationFrame(this.frame)
    document.removeEventListener("turbo:load", this.pageChanged)
  }

  // Height = the screen below where the chat sits when the page is scrolled to
  // the top: the top of the row it lives in, which doesn't move when it sticks.
  fit() {
    if (this.phone.matches || !this.element.parentElement) {
      this.element.style.removeProperty("--ooc-sidebar-height")
      return
    }
    const top = Math.max(0, this.element.parentElement.getBoundingClientRect().top + window.scrollY)
    this.element.style.setProperty("--ooc-sidebar-height", `${Math.max(200, window.innerHeight - top)}px`)
  }

  toggle() {
    const collapsed = !this.collapsed
    this.apply(collapsed)
    // Opening or closing it on an admin page lasts until you leave the admin panel.
    if (!onAdminPage) this.write("ooc-sidebar", collapsed ? "collapsed" : "open")
    this.refresh()
  }

  // The chat stays on screen between pages, so it watches for moving
  // into or out of the admin panel.
  followPage() {
    const admin = this.isAdminPage()
    if (admin === onAdminPage) return
    onAdminPage = admin
    this.apply(admin || this.read("ooc-sidebar") === "collapsed")
    if (this.hasMessagesTarget) this.refresh()
  }

  isAdminPage() {
    return document.body.classList.contains("is-admin")
  }

  apply(collapsed) {
    this.element.classList.toggle("ooc-sidebar--collapsed", collapsed)
    this.toggleTarget.setAttribute("aria-expanded", String(!collapsed))
    this.toggleTarget.title = collapsed ? "Show OOC Chat" : "Hide OOC Chat"
  }

  // Shows the unread count while folded; while open, everything counts as seen.
  refresh() {
    if (!this.collapsed) {
      this.markSeen()
      this.showCount(0)
      return
    }
    const lastSeen = Number(this.read("ooc-last-seen")) || 0
    this.showCount(this.messageIds().filter(id => id > lastSeen).length)
  }

  showCount(count) {
    this.countTarget.hidden = count === 0
    this.countTarget.textContent = count > 99 ? "99+" : String(count)
    this.toggleTarget.setAttribute("aria-label", count ? `OOC Chat, ${count} unread` : "OOC Chat")
  }

  markSeen() {
    this.write("ooc-last-seen", String(Math.max(0, ...this.messageIds())))
  }

  // Each message's id comes from its element id, such as "ooc_message_42".
  messageIds() {
    return Array.from(this.messagesTarget.children, el => Number(el.id.replace("ooc_message_", ""))).filter(Boolean)
  }

  get collapsed() {
    return this.element.classList.contains("ooc-sidebar--collapsed")
  }

  read(key) {
    try { return localStorage.getItem(key) } catch { return null }
  }

  write(key, value) {
    try { localStorage.setItem(key, value) } catch {}
  }
}
