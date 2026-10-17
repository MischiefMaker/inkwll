import { Controller } from "@hotwired/stimulus"

// In the roll box: when the Skill changes, tick the Boons and Banes that
// affect it and untick the rest. The player can still change any tick.
export default class extends Controller {
  static targets = [ "skill", "bnb" ]

  connect() {
    this.pick()
  }

  pick() {
    const skillId = this.skillTarget.value
    this.bnbTargets.forEach((box) => {
      box.checked = box.dataset.skillIds.split(",").includes(skillId)
    })
  }
}
