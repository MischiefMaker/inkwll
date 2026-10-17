import { Controller } from "@hotwired/stimulus"

// "Give me an idea" on the new Chapter form: copies a random staff-written
// idea into the title and subtitle boxes, a different one each click.
export default class extends Controller {
  static targets = ["title", "subtitle"]
  static values = { ideas: Array }

  pick(event) {
    event.preventDefault()
    const ideas = this.ideasValue
    if (ideas.length === 0) return
    let index = Math.floor(Math.random() * ideas.length)
    if (ideas.length > 1 && index === this.lastIndex) index = (index + 1) % ideas.length
    this.lastIndex = index
    this.titleTarget.value = ideas[index].title
    this.subtitleTarget.value = ideas[index].subtitle
    this.titleTarget.focus()
  }
}
