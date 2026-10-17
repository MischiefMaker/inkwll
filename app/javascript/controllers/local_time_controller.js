import { Controller } from "@hotwired/stimulus"

// Shows a <time datetime="..."> in the reader's own time zone. The page
// prints it in UTC first, which stays if JavaScript is off.
export default class extends Controller {
  connect() {
    const when = new Date(this.element.getAttribute("datetime"))
    if (isNaN(when)) return
    this.element.textContent = when.toLocaleString(undefined, { weekday: "short", day: "numeric", month: "long", year: "numeric", hour: "numeric", minute: "2-digit", timeZoneName: "short" })
  }
}
