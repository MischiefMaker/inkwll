import { Controller } from "@hotwired/stimulus"

// The admin menu starts open. On a phone-sized screen it folds into
// one "Admin menu" button at the top of the page instead.
export default class extends Controller {
  connect() {
    if (window.matchMedia("(max-width: 800px)").matches) this.element.open = false
  }
}
