import { Controller } from "@hotwired/stimulus"

// A browser pop-up when a new Message arrives, for players who turned
// pop-ups on (any setting except "No pop-ups" and "Only when it's my turn").
// Remembers the newest one shown, so moving between pages doesn't repeat it.
export default class extends Controller {
  static values = { count: Number, level: String, latest: Number }

  connect() {
    if (!["all", "after_minutes"].includes(this.levelValue)) return
    if (!("Notification" in window) || Notification.permission !== "granted") return

    // The first time, start counting from now, so old messages don't pop up.
    const seen = remembered()
    if (seen === null) return remember(this.latestValue || Math.floor(Date.now() / 1000))
    if (!this.latestValue || this.latestValue <= seen) return
    if (window.location.pathname.startsWith("/messages")) return remember(this.latestValue)

    remember(this.latestValue)
    const notification = new Notification("Inkwll", { body: "You have a new message.", tag: "messages", icon: "/icon.png" })
    notification.onclick = () => { window.focus(); window.Turbo.visit(this.element.href); notification.close() }
  }
}

function remembered() {
  try {
    const value = localStorage.getItem("inkwll-notified-messages")
    return value ? Number(value) : null
  } catch { return null }
}

function remember(value) {
  try { localStorage.setItem("inkwll-notified-messages", String(value)) } catch {}
}
