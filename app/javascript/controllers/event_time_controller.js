import { Controller } from "@hotwired/stimulus"

// The event form's start time. The player types it in their own time zone;
// this sends their offset from UTC for that date, so the server can store
// the right moment. When editing, it first turns the stored UTC time into
// the player's local time.
export default class extends Controller {
  static targets = ["field", "offset"]
  static values = { utc: String }

  connect() {
    if (this.utcValue) {
      const when = new Date(this.utcValue)
      if (!isNaN(when)) {
        const local = new Date(when.getTime() - when.getTimezoneOffset() * 60000)
        this.fieldTarget.value = local.toISOString().slice(0, 16)
      }
    }
    this.update()
  }

  update() {
    const typed = new Date(this.fieldTarget.value)
    this.offsetTarget.value = isNaN(typed) ? new Date().getTimezoneOffset() : typed.getTimezoneOffset()
  }
}
