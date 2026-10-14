import { Controller } from "@hotwired/stimulus"

// Keeps a chat log scrolled to the newest message when new ones arrive.
export default class extends Controller {
  connect() {
    this.scroll()
    this.observer = new MutationObserver(() => this.scroll())
    this.observer.observe(this.element, { childList: true })
  }

  disconnect() {
    this.observer.disconnect()
  }

  scroll() {
    this.element.scrollTop = this.element.scrollHeight
  }
}
