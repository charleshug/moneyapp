import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="trx-toggle"
export default class extends Controller {
  static values = { url: String }
  static targets = ["lines", "circle", "amount", "cleared"]

  toggle() {
    if (this.hasLinesTarget) {
      this.linesTarget.classList.toggle("hidden")
      let svg_icon = this.element.getElementsByClassName('svg-arrow')[0]
      svg_icon.classList.toggle('rotate-90')
    }
  }

  toggleSelect() {
    this.element.classList.toggle('selected')
    let circle_icon = this.circleTarget
    circle_icon.classList.toggle('fill-sky-500')
    this.element.classList.toggle('bg-slate-200')

    this.calculateTrxTotal()
  }

  toggleCleared() {
    //console.log("toggled transaction cleared")
    // let temp_icon = this.element.getElementsByClassName('cleared-svg')[0]
    // temp_icon.classList.toggle('fill-green-700')
    // temp_icon.classList.toggle('fill-white')
    // temp_icon.classList.toggle('bg-green-700')
    let formData = new FormData()
    formData.append("trx[cleared]", this.clearedTarget.checked)
    //console.log(formData)
    const token = document.getElementsByName("csrf-token")[0].content;
    fetch(this.urlValue,{
      body:formData,
      method: 'PATCH',
      dataType: 'script',
      credentials: 'include',
      headers: {
        "X-CSRF-Token": token
      },
    })
    this.updateClearedAmounts(this.amountTarget.innerText,this.clearedTarget.checked)
  }

  connect() {
    //console.log("hi")
  }

  updateClearedAmounts(TrxAmountString,clearedAction){
    let changedAmountString = TrxAmountString
    let changedAmount = parseInt(changedAmountString.replace("$", "").replace(".", "").replace(",", ""))
    let clearedAmountString = document.getElementById('clearedAmount')
    let clearedAmount = parseInt(clearedAmountString.innerText.replace("$", "").replace(".", "").replace(",",""))
    let unclearedAmountString = document.getElementById('unclearedAmount')
    let unclearedAmount = parseInt(unclearedAmountString.innerText.replace("$", "").replace(".", "").replace(",", ""))

    if (clearedAction) {
      clearedAmount += changedAmount;
      unclearedAmount -= changedAmount;
    } else {
      clearedAmount -= changedAmount;
      unclearedAmount += changedAmount;
    }

    const formatter = new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD', minimumFractionDigits: 2, maximumFractionDigit: 2 })
    clearedAmountString.innerText = formatter.format(clearedAmount/100)
    unclearedAmountString.innerText = formatter.format(unclearedAmount/100)
  }

  calculateTrxTotal() {
    let items = Array.from(document.getElementsByClassName('selected'))
    let amount_array = items.flatMap(element => parseFloat(element.getElementsByClassName('trx-amount')[0].innerHTML.replace(/,/g, '')))
    
    const initialValue = 0 //initial value required in case array is deselected to zero items
    let array_total = amount_array.reduce((acc, curr) => acc + curr, initialValue)
    
    let display_amount = ""
    let display_text = ""
    
    if (!isNaN(array_total) && amount_array.length > 0 ) {
      const formatter = new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD', minimumFractionDigits: 2, maximumFractionDigit: 2 })
      display_amount = formatter.format(array_total)
      display_text = "Selected Total (" + amount_array.length + ")"      
    }
    
    let display_text_div = document.getElementById('trx-selected-text')
    let display_amount_div = document.getElementById('trx-selected-amount')

    display_text_div.innerText = display_text
    display_amount_div.innerText = display_amount
  }

}
