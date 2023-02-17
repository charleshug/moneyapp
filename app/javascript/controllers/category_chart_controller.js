import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="category-chart"
export default class extends Controller {

  static values = { id: String,
                    categoryFilter: String,
                    url: String, }

  static targets = ['category' ]

  connect() {
    console.log('category chart controller')
    console.log(this.idValue)
    console.log(this.urlValue)

    var chart = Chartkick.charts[this.idValue]
    let _this = this
    
    let chartConfig = chart.getChartObject().config
    chartConfig.options.onClick = function (event,native,active){
      if(native.length > 0) {
        let pieSlice = native[0].index
        let label = chart.getChartObject().data.labels[pieSlice]
        //console.log(label)
        _this.categoryFilterValue = label
        _this.loadChart()
        
      }
    }
  }

  loadChart(){
    console.log(fetch(this.urlValue + "?" + new URLSearchParams({ category_filter: this.categoryFilterValue })) 
      .then(response => response.text())
      .then(html => {
        this.categoryTarget.innerHTML = html;
      })
    )
  }
}
