import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="trx-toggle"
export default class extends Controller {
  static values = { url: String, 
                    cleared: Boolean
                  }
  static targets = ["lines", "circle", "amount", "cleared"]

  toggle() {
    if (this.hasLinesTarget) {
      this.linesTarget.classList.toggle("hidden")
      let svg_icon = this.element.getElementsByClassName('svg-arrow')[0]
      svg_icon.classList.toggle('rotate-90')
    }
  }

  toggleSelect() {
  //   this.element.classList.toggle('selected')
  //   let circle_icon = this.circleTarget
  //   circle_icon.classList.toggle('fill-sky-500')
  //   this.element.classList.toggle('bg-slate-200')

    this.calculateTrxTotal()
  }

  select_all() {
    document.querySelectorAll("#selected_trxes_ids_").forEach(function (el) {
      el.checked = true
    })
    this.toggleSelect()
  }

  deselect_all() {
    document.querySelectorAll("#selected_trxes_ids_").forEach(function (el) {
      el.checked = false
    })
    this.toggleSelect()
  }

  toggle_selected() {
    document.querySelectorAll("#selected_trxes_ids_").forEach(function (el) {
      el.checked = !el.checked
    })
    this.toggleSelect()
  }

  toggleCleared() {
    let formData = new FormData()
    formData.append("trx[cleared]", !this.clearedValue) // "true" or "false"
    const token = document.getElementsByName("csrf-token")[0].content;
    fetch(this.urlValue,{
      body:formData,
      method: 'PATCH',
      dataType: 'script',
      credentials: 'include',
      headers: {
        "X-CSRF-Token": token,
        "Accept": "text/vnd.turbo-stream.html, text/html, application/xhtml+xml"
      },
    })
    .then(response => response.text())
    .then(text => Turbo.renderStreamMessage(text));
    this.updateClearedAmounts(this.amountTarget.innerText,!this.clearedValue)
  }

  connect() {
    this.calculateTrxTotal()
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
    let display_text_div = document.getElementById('trx-selected-text')
    let display_amount_div = document.getElementById('trx-selected-amount')

    let all = document.querySelectorAll('.trx_item')
    if (all.empty) {
      display_text_div.innerText = "Selected Total ( 0 )"
      display_amount_div.innerText = "$0.00"
      document.querySelector('#trx-selected-box').classList.add('hidden')
      return
    }
    document.querySelector('#trx-selected-box').classList.remove('hidden')
    let sum_selected = 0
    let count_selected = 0
    all.forEach(function (el) {
      let boxChecked = el.querySelector('#selected_trxes_ids_').checked
      if (boxChecked === true) {
        let el_amount = Number(el.querySelector('.trx-amount').innerText.replace(',', ''))
        sum_selected += el_amount
        count_selected += 1
      }
    })

    if (count_selected == 0) {
      display_text_div.innerText = "Selected Total ( 0 )"
      display_amount_div.innerText = "$0.00"
      document.querySelector('#trx-selected-box').classList.add('hidden')
      return
    }

    sum_selected = Math.round(sum_selected * 100) / 100
    const formatter = new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD', minimumFractionDigits: 2, maximumFractionDigit: 2 })
    let display_amount = formatter.format(sum_selected)

    let display_text = "Selected Total (" + count_selected + ")"

    display_text_div.innerText = display_text
    display_amount_div.innerText = display_amount

  }

}
