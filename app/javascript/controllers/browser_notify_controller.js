import { Controller } from "@hotwired/stimulus"

// Browser pop-ups about the player's Chapters, following their notification
// settings. Works from the Chapter tabs, which reload whenever something
// happens, so pop-ups only appear while the site is open in a tab.
//
// What's been shown is remembered in the browser, so moving between pages
// (or having two tabs open) doesn't show the same pop-up twice.
export default class extends Controller {
  static targets = ["tab"]
  static values = { level: String, minutes: Number }

  connect() {
    if (this.levelValue === "after_minutes") this.timer = setInterval(() => this.check(), 30_000)
    this.check()
  }

  disconnect() {
    clearInterval(this.timer)
  }

  check() {
    if (this.levelValue === "off" || !("Notification" in window) || Notification.permission !== "granted") return

    for (const tab of this.tabTargets) {
      const scene = tab.dataset.sceneId
      const unread = Number(tab.dataset.unreadCount)
      const sequence = Number(tab.dataset.sequence)
      const turn = tab.dataset.turn
      const reading = document.visibilityState === "visible" && window.location.pathname === new URL(tab.href).pathname
      const seen = remembered(scene)

      // The first time a Chapter shows up here, just note where it stands.
      if (seen === null) { remember(scene, { sequence, turn }); continue }
      if (reading) { remember(scene, { sequence, turn }); continue }

      if (this.levelValue === "all" && unread > 0 && sequence > seen.sequence) {
        this.show(tab, `${unread} new in ${tab.dataset.title}`)
      } else if (this.levelValue === "my_turn" && turn && turn !== seen.turn) {
        this.show(tab, `Your turn in ${tab.dataset.title}`)
      } else if (this.levelValue === "after_minutes" && unread > 0 && sequence > seen.sequence && tab.dataset.waitingSince &&
                 Date.now() - Date.parse(tab.dataset.waitingSince) >= this.minutesValue * 60_000) {
        this.show(tab, `${unread} waiting in ${tab.dataset.title}`)
      } else {
        // Keep track of turns even when no pop-up was due, so an old turn doesn't pop up later.
        if (turn !== seen.turn) remember(scene, { sequence: seen.sequence, turn })
        continue
      }
      remember(scene, { sequence, turn })
    }
  }

  show(tab, body) {
    // One pop-up per Chapter: a newer one replaces the old.
    const notification = new Notification("Inkwll", { body, tag: `chapter-${tab.dataset.sceneId}`, icon: "/icon.png" })
    notification.onclick = () => { window.focus(); window.Turbo.visit(tab.href); notification.close() }
  }
}

function remembered(scene) {
  try {
    const value = localStorage.getItem(`inkwll-notified-${scene}`)
    return value ? JSON.parse(value) : null
  } catch { return null }
}

function remember(scene, state) {
  try { localStorage.setItem(`inkwll-notified-${scene}`, JSON.stringify(state)) } catch {}
}
