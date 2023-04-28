import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="slideover"
export default class extends Controller {
  static targets = ["slideover", "form"]

  connect() {
    this.visible = false

    // must define this.escapeKey here instead of in open() and close(), because
    // .bind(this) used in open() and close() for 'keydown' changed the signature
    // and the eventListener was added but its match was not found in order to be removed
    this.escapeKey = this.closeHandler.bind(this)
  }

  disconnect() {
    if (this.visible) {
      this.close()
    }
  }
  
  closeHandler(event) {
    if (event.keyCode == 27) {
      this.close();
    }
  }

  open() {
    this.visible = true
    document.body.insertAdjacentHTML('beforeend', this.backgroundHTML())
    document.addEventListener("keydown", this.escapeKey)
    this.background = document.querySelector(`#slideover-background`)
    this.background.addEventListener("click", this.close.bind(this))
    this.toggleSlideover()
  }

  close() {
    this.visible = false
    document.removeEventListener("keydown", this.escapeKey)
    this.toggleSlideover()
    this.removeDimmedBackground()
  }

  removeDimmedBackground() {
    if (this.background) {
      this.background.classList.remove("opacity-100")
      this.background.classList.add("opacity-0")
      setTimeout(() => {
        this.background.remove()
      }, 500);
    }
  }

  toggleSlideover() {
    this.slideoverTarget.classList.toggle("right-0")
    this.slideoverTarget.classList.toggle("-right-full")
    this.slideoverTarget.classList.toggle("lg:-right-1/3")
  }

  backgroundHTML() {
    return `<div id="slideover-background" class="fixed top-0 left-0 w-full h-full z-20"></div>`;
  }

  handleResponse({ detail: { success } }) {
    if (success) {
      this.formTarget.reset()
      this.close()
    }
  }
}
