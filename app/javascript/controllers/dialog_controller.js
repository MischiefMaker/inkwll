import { Controller } from "@hotwired/stimulus"

// Opens and closes a modal pop-up (a <dialog> element). A click on the dark
// area around the box closes it too.
export default class extends Controller {
  static targets = ["box"]

  open(event) {
    event?.preventDefault()
    this.boxTarget.showModal()
  }

  close(event) {
    event?.preventDefault()
    this.boxTarget.close()
  }

  backdrop(event) {
    if (event.target === this.boxTarget) this.boxTarget.close()
  }
}
