import { Controller } from "@hotwired/stimulus"

// Folds the OOC Chat into the right edge and brings it back out.
// While it's folded, the tab counts messages the player hasn't seen.
// Remembers both the choice and the last message seen in this browser.
export default class extends Controller {
  static targets = ["toggle", "count", "messages"]

  connect() {
    this.apply(this.read("ooc-sidebar") === "collapsed")
    if (this.read("ooc-last-seen") === null) this.markSeen()
    this.refresh()
    this.observer = new MutationObserver(() => this.refresh())
    this.observer.observe(this.messagesTarget, { childList: true })
  }

  disconnect() {
    this.observer.disconnect()
  }

  toggle() {
    const collapsed = !this.collapsed
    this.apply(collapsed)
    this.write("ooc-sidebar", collapsed ? "collapsed" : "open")
    this.refresh()
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
