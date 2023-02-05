import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="toggle"
export default class extends Controller {
  static classes = ["change"]
  static targets = ["numpad"]

  toggle() {
    this.numpadTarget.classList.toggle(this.changeClass)
  }
}