import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="budget-detail"
export default class extends Controller {
  static targets = ['childGroup']
  
  toggle() {
    this.childGroupTarget.classList.toggle('hidden')
  }

}
