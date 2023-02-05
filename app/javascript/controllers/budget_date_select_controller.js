import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="budget-date-select"
export default class extends Controller {
  connect() {
  }

  goToDate(){
    //console.log(this.element.value)
    let xhr = new XMLHttpRequest();
    let url = "/budgets?period=" + this.element.value + "-01"
    console.log(url)
    xhr.open("GET", url)
    xhr.send()
  }
}
