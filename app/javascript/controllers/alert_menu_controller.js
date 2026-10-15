import { Controller } from "@hotwired/stimulus"

// The header's alerts drop-down: loads the latest alerts each time it
// opens (which marks them read), and closes on a click elsewhere.
export default class extends Controller {
  static targets = ["frame"]

  toggle() {
    if (!this.element.open) return
    const frame = this.frameTarget
    if (frame.src) frame.reload()
    else frame.src = frame.dataset.src
  }

  closeOutside(event) {
    if (this.element.open && !this.element.contains(event.target)) this.element.open = false
  }
}
