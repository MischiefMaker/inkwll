import { Controller } from "@hotwired/stimulus"

// The tabs in the chat sidebar: the OOC Chat, one per live private chat and
// one for sending a page. Remembers the open tab in this browser, marks the
// player's own messages, flags tabs with new messages, and tells the server
// when a private chat has been read.
export default class extends Controller {
  static targets = ["tab", "pane", "messages", "panel"]

  connect() {
    this.current = this.read() || "ooc"
    this.apply()
  }

  show(event) {
    this.current = event.currentTarget.dataset.pane
    this.write(this.current)
    this.apply()
  }

  panelTargetConnected(panel) {
    if (panel.dataset.open) {
      this.current = panel.dataset.open
      this.write(this.current)
    }
    this.apply()
  }

  messagesTargetConnected(list) {
    this.markMine(list)
    list.scrollTop = list.scrollHeight
    list._observer = new MutationObserver(() => this.arrived(list))
    list._observer.observe(list, { childList: true })
  }

  messagesTargetDisconnected(list) {
    list._observer?.disconnect()
  }

  arrived(list) {
    this.markMine(list)
    list.scrollTop = list.scrollHeight
    const pane = list.closest("[data-pane]")
    if (pane.dataset.pane === this.current) this.markRead(pane)
    else this.tabFor(pane.dataset.pane)?.classList.add("chat-tabs__tab--unread")
  }

  // Clears the box after a message or page goes through.
  sent(event) {
    if (event.detail.success) event.target.reset()
  }

  apply() {
    if (!this.tabTargets.some(tab => tab.dataset.pane === this.current)) this.current = "ooc"
    this.paneTargets.forEach(pane => { pane.hidden = pane.dataset.pane !== this.current })
    this.tabTargets.forEach(tab => {
      const active = tab.dataset.pane === this.current
      tab.classList.toggle("chat-tabs__tab--current", active)
      tab.setAttribute("aria-pressed", active)
    })
    const pane = this.paneTargets.find(pane => pane.dataset.pane === this.current)
    if (pane?.dataset.readUrl) {
      this.tabFor(this.current)?.classList.remove("chat-tabs__tab--unread")
      this.markRead(pane)
      const list = pane.querySelector(".private-chat__messages")
      if (list) list.scrollTop = list.scrollHeight
    }
  }

  markMine(list) {
    const me = list.closest("[data-me]")?.dataset.me
    list.querySelectorAll("[data-member]").forEach(message => {
      message.classList.toggle("private-chat-message--mine", message.dataset.member === me)
    })
  }

  markRead(pane) {
    const token = document.querySelector("meta[name=csrf-token]")?.content
    fetch(pane.dataset.readUrl, { method: "PATCH", headers: { "X-CSRF-Token": token }, credentials: "same-origin" })
  }

  tabFor(key) {
    return this.tabTargets.find(tab => tab.dataset.pane === key)
  }

  read() {
    try { return localStorage.getItem("inkwll-chat-tab") } catch { return null }
  }

  write(value) {
    try { localStorage.setItem("inkwll-chat-tab", value) } catch {}
  }
}
