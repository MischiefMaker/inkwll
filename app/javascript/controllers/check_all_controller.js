import { Controller } from "@hotwired/stimulus"

// A tick box in a table's heading that ticks or unticks every row below it.
export default class extends Controller {
  static targets = ["all", "item"]

  toggle() {
    this.itemTargets.forEach(item => { item.checked = this.allTarget.checked })
  }

  // Keeps the heading's box in step when rows are ticked one by one.
  sync() {
    const ticked = this.itemTargets.filter(item => item.checked).length
    this.allTarget.checked = ticked > 0 && ticked === this.itemTargets.length
    this.allTarget.indeterminate = ticked > 0 && ticked < this.itemTargets.length
  }
}
