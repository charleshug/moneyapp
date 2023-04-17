import { Controller } from "@hotwired/stimulus"
import TomSelect from "tom-select"

// Connects to data-controller="vendor-select"
export default class extends Controller {

  connect() {
    this.element.setAttribute("autocomplete", "random");
    this.initTomSelect()
  }

  disconnect() {
    if (this.select) {
      this.select.destroy()
    }
  }

  initTomSelect() {
    var settings = {
      plugins: ['clear_button'],
      selectOnTab: true,
    }

    this.select = new TomSelect(this.element, settings)
  }
}