import { Controller } from "@hotwired/stimulus"

// In the Storyteller's "Call for a roll" form: shows the Boons and Banes of
// whichever character is picked. Each one starts as "Player's choice"; the
// Storyteller can change any of them before calling.
export default class extends Controller {
  static targets = [ "character", "group" ]

  connect() {
    this.show()
  }

  show() {
    const id = this.characterTarget.value
    this.groupTargets.forEach((group) => { group.hidden = group.dataset.characterId !== id })
  }
}
