import { Controller } from "@hotwired/stimulus"

// On the notification settings page: asks the browser for permission to show
// pop-ups when the player picks an option other than "No pop-ups", and says
// whether the browser has allowed it.
export default class extends Controller {
  static targets = ["status"]

  connect() {
    this.showStatus()
  }

  async ask(event) {
    if (event.target.value === "off" || !("Notification" in window)) return this.showStatus()
    if (Notification.permission === "default") await Notification.requestPermission()
    this.showStatus()
  }

  showStatus() {
    if (!this.hasStatusTarget) return
    if (!("Notification" in window)) {
      this.statusTarget.textContent = "This browser can't show pop-ups."
    } else if (Notification.permission === "denied") {
      this.statusTarget.textContent = "Your browser is blocking pop-ups from this site. You can allow them in the browser's site settings."
    } else if (Notification.permission === "granted") {
      this.statusTarget.textContent = "Your browser allows pop-ups from this site."
    } else {
      this.statusTarget.textContent = "Your browser will ask whether to allow pop-ups when you pick one."
    }
  }
}
