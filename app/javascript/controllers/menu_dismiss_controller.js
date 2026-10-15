import { Controller } from "@hotwired/stimulus"

// A <details> drop-down that closes when you click anywhere else.
export default class extends Controller {
  closeOutside(event) {
    if (this.element.open && !this.element.contains(event.target)) this.element.open = false
  }
}
