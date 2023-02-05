import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="budget-dashboard"
export default class extends Controller {
  static targets = ['dashboard']

  toggle(){
    this.dashboardTarget.classList.toggle('hidden')
  }
}
