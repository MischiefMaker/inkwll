import { Controller } from "@hotwired/stimulus"

// Shows how many starting points are left on a SOUL sheet as the player
// changes Resonance and ratings. The server checks the totals again on save.
export default class extends Controller {
  static targets = [ "resonance", "aspect", "skill", "aspectsLeft", "skillsLeft", "cap" ]
  static values = { allowances: Object }

  connect() { this.update() }

  update() {
    const resonance = this.hasResonanceTarget ? this.resonanceTarget.value : "0"
    const allowance = this.allowancesValue[resonance] || this.allowancesValue["0"]
    if (!allowance) return
    const sum = (inputs) => inputs.reduce((total, input) => total + (parseInt(input.value, 10) || 0), 0)
    this.aspectsLeftTarget.textContent = allowance.aspect_points - sum(this.aspectTargets)
    this.skillsLeftTarget.textContent = allowance.skill_points - sum(this.skillTargets)
    this.capTarget.textContent = allowance.starting_cap
    this.skillTargets.forEach((input) => input.max = allowance.starting_cap)
  }
}
