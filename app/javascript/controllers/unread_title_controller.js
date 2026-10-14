import { Controller } from "@hotwired/stimulus"

// Shows how many Passages are waiting in the browser tab: "(3) Inkwll", and a
// dot on the site icon. The Chapter on screen doesn't count.
export default class extends Controller {
  static targets = ["total"]

  connect() {
    this.update = this.update.bind(this)
    // A live page update resets the title and icon, so put the count back.
    for (const name of ["turbo:morph", "turbo:load", "visibilitychange"]) document.addEventListener(name, this.update)
    this.update()
  }

  disconnect() {
    for (const name of ["turbo:morph", "turbo:load", "visibilitychange"]) document.removeEventListener(name, this.update)
    this.show(0)
  }

  totalTargetConnected() {
    this.update()
  }

  update() {
    let total = this.hasTotalTarget ? Number(this.totalTarget.dataset.total) : 0
    const current = this.element.querySelector(".chapter-tab--current [data-unread]")
    if (current && document.visibilityState === "visible") total -= Number(current.dataset.unread)
    this.show(Math.max(0, total))
  }

  show(count) {
    const title = document.title.replace(/^\(\d+\) /, "")
    document.title = count > 0 ? `(${count}) ${title}` : title
    setFavicon(count > 0)
  }
}

// Swaps the site icons for a copy with a dot, and back.
function setFavicon(dot) {
  const links = Array.from(document.querySelectorAll("link[rel='icon']"))
  links.forEach(link => {
    if (!link.dataset.original) {
      link.dataset.original = link.href
      link.dataset.originalType = link.type
    }
  })

  if (!dot) {
    links.forEach(link => { link.href = link.dataset.original; link.type = link.dataset.originalType })
    return
  }

  const png = links.find(link => link.dataset.originalType === "image/png")
  if (!png) return
  const image = new Image()
  image.onload = () => {
    const canvas = document.createElement("canvas")
    canvas.width = canvas.height = 64
    const context = canvas.getContext("2d")
    context.drawImage(image, 0, 0, 64, 64)
    context.fillStyle = "#d33"
    context.beginPath()
    context.arc(48, 16, 14, 0, 2 * Math.PI)
    context.fill()
    const dotted = canvas.toDataURL("image/png")
    links.forEach(link => { link.href = dotted; link.type = "image/png" })
  }
  image.src = png.dataset.original
}
