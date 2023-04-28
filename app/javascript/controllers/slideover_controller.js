import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="slideover"
export default class extends Controller {
  static targets = ["slideover", "form"]

  connect() {
    this.visible = false
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
    document.addEventListener("keydown", this.closeHandler.bind(this))
    this.background = document.querySelector(`#slideover-background`)
    this.background.addEventListener("click", this.close.bind(this))
    this.toggleSlideover()
  }

  close() {
    this.visible = false
    this.background.removeEventListener("keydown", this.closeHandler.bind(this))
    this.toggleSlideover()
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
