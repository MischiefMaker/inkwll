import { Controller } from "@hotwired/stimulus"

// The admin "Build several Settings" screen. Adds and removes Setting and
// Path rows, and keeps each Path's "From" and "Leads to" menus listing the
// new Settings by the names typed so far. The server checks everything on save.
export default class extends Controller {
  static targets = [ "rooms", "roomTemplate", "paths", "pathTemplate" ]
  static values = { roomTerm: String }

  connect() { this.refresh() }

  addRoom() {
    const row = this.addRow(this.roomTemplateTarget, this.roomsTarget)
    row.querySelector("input")?.focus()
  }

  addPath() {
    this.addRow(this.pathTemplateTarget, this.pathsTarget)
  }

  remove(event) {
    event.target.closest("[data-key]").remove()
    this.refresh()
  }

  // Renumbers the Setting boxes and rebuilds the "New Settings" choice in
  // every Path menu, keeping whatever was already picked.
  refresh() {
    const rooms = [ ...this.roomsTarget.querySelectorAll(".bulk-build__room") ]
    rooms.forEach((room, index) => {
      room.querySelector(".bulk-build__room-number").textContent = `${this.roomTermValue} ${index + 1}`
    })

    this.element.querySelectorAll(".bulk-build__paths .bulk-build__room-select").forEach((select) => {
      const picked = select.value
      const group = select.querySelector(".bulk-build__new-rooms")
      group.replaceChildren(...rooms.map((room, index) => {
        const name = room.querySelector("input").value.trim()
        return new Option(name || `${this.roomTermValue} ${index + 1} (no name yet)`, `new-${room.dataset.key}`)
      }))
      select.value = picked
      if (select.value !== picked) select.value = ""
    })
  }

  addRow(template, list) {
    this.nextKey = (this.nextKey || Date.now()) + 1
    const html = template.innerHTML.replaceAll("KEY", this.nextKey)
    list.insertAdjacentHTML("beforeend", html)
    this.refresh()
    return list.lastElementChild
  }
}
