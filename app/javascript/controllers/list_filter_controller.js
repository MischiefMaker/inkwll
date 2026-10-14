import { Controller } from "@hotwired/stimulus"

// Narrows a long list as you type, for a building with many numbered
// doors. Items whose text doesn't contain what was typed are hidden.
export default class extends Controller {
  static targets = [ "input", "item" ]

  filter() {
    const query = this.inputTarget.value.trim().toLowerCase()
    this.itemTargets.forEach(item => {
      item.hidden = query !== "" && !item.textContent.toLowerCase().includes(query)
    })
  }
}
