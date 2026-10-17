import { Controller } from "@hotwired/stimulus"

// In the Storyteller's "Call for a roll" form: shows the Boons and Banes of
// whichever character is picked, and presets each one for the picked Skill
// ("Player's choice" if it affects the Skill, otherwise "Doesn't count").
// The Storyteller can change any of them before calling.
export default class extends Controller {
  static targets = [ "character", "skill", "group", "ruling" ]

  connect() {
    this.show()
  }

  show() {
    const id = this.characterTarget.value
    this.groupTargets.forEach((group) => { group.hidden = group.dataset.characterId !== id })
    this.preset()
  }

  preset() {
    const skillId = this.skillTarget.value
    this.rulingTargets.forEach((select) => {
      select.value = select.dataset.skillIds.split(",").includes(skillId) ? "choice" : "no"
    })
  }
}
