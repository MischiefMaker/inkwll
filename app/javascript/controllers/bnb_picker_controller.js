import { Controller } from "@hotwired/stimulus"

// In the roll box: when the Skill changes, tick the Boons and Banes that
// affect it and untick the rest. The player can still change any tick.
// On the Craft page the choice is an item type, whose option names its
// Skill in data-skill-id.
export default class extends Controller {
  static targets = [ "skill", "bnb" ]

  connect() {
    this.pick()
  }

  pick() {
    const option = this.skillTarget.selectedOptions && this.skillTarget.selectedOptions[0]
    const skillId = (option && option.dataset.skillId) || this.skillTarget.value
    this.bnbTargets.forEach((box) => {
      box.checked = box.dataset.skillIds.split(",").includes(skillId)
    })
  }
}
