import { Controller } from "@hotwired/stimulus"
import TomSelect from "tom-select"

// Connects to data-controller="vendor-select"
export default class extends Controller {
  static values = {
    url: String,
    options: Array,
  }

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
      //placeholder: "Choose Vendor", //overrides prompt specified by form template
      selectOnTab: true,
      valueField: 'id',
      labelField: 'name', //necessary when using default render: option/item
      searchField: 'name',
      sortField: { field: "name", direction: "asc" },
    }

    this.select = new TomSelect(this.element, settings)
  }

  search(query, callback) {
    console.log("search called")
    fetch(this.urlValue + ".json")
      .then(response => response.json())
      .then(json => {
        callback(json);
      }).catch(() => {
        callback();
      });
  }
  
  // This is only needed if labelField: 'name' isn't specified in settings
  // render_option(data, escape) {
  //   return '<div>' + escape(data.name) + '</div>';
  // }
}
