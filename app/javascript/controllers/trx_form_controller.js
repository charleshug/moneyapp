import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="trx-form"
export default class extends Controller {
  static targets = ["formAmount","displayAmount"]

  connect() {
    //console.log('DEBUG: JS trx_form_controller')
    this.setDisplayAmount()
  }

  handleNumber(){
    let displayAmount = this.displayAmountTarget.innerText
    let formAmount = this.formAmountTarget.value
    let amountString = formAmount.toString()
    
    event.currentTarget.innerText === 'Back'
      ? amountString = amountString.slice(0, -1)
      : amountString += event.currentTarget.innerText
    
    if (amountString === '' ) { amountString = "0" }
    let parsedValue = parseInt(amountString)
    this.formAmountTarget.value = parsedValue

    const formatter = new Intl.NumberFormat('en-US', {style: 'currency', currency: 'USD'})
    displayAmount = formatter.format(parsedValue /100.00)
    this.displayAmountTarget.innerText = displayAmount

  }

  setDisplayAmount(){
    // console.log('DEBUG: setDisplayAmount')
    let displayAmount = this.displayAmountTarget
    let formAmount = this.formAmountTarget.value

    const formatter = new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' })
    displayAmount = formatter.format(formAmount / 100.00)
    this.displayAmountTarget.innerText = displayAmount

    if (formAmount < 0) {
      this.displayAmountTarget.classList.toggle('text-green-500')
      this.displayAmountTarget.classList.toggle('text-red-500')

      let expense_box = document.querySelector('#expense_box')
      let income_box = document.querySelector('#income_box')
      expense_box.classList.add('text-white')
      expense_box.classList.add('bg-red-500')
      expense_box.classList.remove('text-black')
      expense_box.classList.remove('bg-white')
      income_box.classList.add('text-black')
      income_box.classList.add('bg-white')
      income_box.classList.remove('text-white')
      income_box.classList.remove('bg-green-500')
    }
  }


}
