import { Controller } from "@hotwired/stimulus"

// Edit / Preview tabs on the wiki page form. Preview asks the server to draw
// the page (the same way a saved page is drawn) without saving anything.
export default class extends Controller {
  static targets = [ "body", "preview", "editTab", "previewTab" ]
  static values = { url: String }

  edit() {
    this.bodyTarget.hidden = false
    this.previewTarget.hidden = true
    this.editTabTarget.classList.add("is-current")
    this.previewTabTarget.classList.remove("is-current")
  }

  async show() {
    this.bodyTarget.hidden = true
    this.previewTarget.hidden = false
    this.previewTabTarget.classList.add("is-current")
    this.editTabTarget.classList.remove("is-current")
    this.previewTarget.textContent = "Loading preview…"
    const body = new FormData()
    body.append("body", this.bodyTarget.value)
    try {
      const response = await fetch(this.urlValue, {
        method: "POST",
        body,
        headers: { "X-CSRF-Token": document.querySelector("meta[name=csrf-token]")?.content }
      })
      if (!response.ok) throw new Error(response.status)
      this.previewTarget.innerHTML = await response.text()
    } catch {
      this.previewTarget.textContent = "Sorry, the preview could not be loaded."
    }
  }
}
