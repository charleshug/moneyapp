import { Controller } from "@hotwired/stimulus"
import TomSelect from "tom-select"

// Connects to data-controller="vendor-select"
export default class extends Controller {
  static values = {
    url: String,
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
      labelField: 'name', //necessary when using default render: option/item.
      searchField: 'name',
      sortField: { field: "name", direction: "asc" },
      create: function (input, callback) {
        const data = { name: input }
        const token = document.getElementsByName("csrf-token")[0].content;
        fetch('/vendors', {
          body: JSON.stringify(data),
          method: 'POST',
          dataType: 'script',
          credentials: 'include',
          headers: {
            "X-CSRF-Token": token,
            "Content-Type": "application/json",
            "Accept": "application/json"
          },
        }).then((response) => { return response.json() })
          // .then((data) => { callback({ id: data.id, name: data.name }) })
          .then((data) => { callback(data) })
      },
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