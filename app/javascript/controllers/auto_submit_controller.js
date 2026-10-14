import { Controller } from "@hotwired/stimulus"

// Submits the surrounding form as soon as a field changes.
// Used by the character switcher dropdown.
export default class extends Controller {
  submit() {
    this.element.requestSubmit()
  }
}
