import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="trx-form"
export default class extends Controller {
  static targets = ["formAmount","displayAmount"]

  connect() {
    console.log('DEBUG: JS trx_form_controller')
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
    console.log('DEBUG: setDisplayAmount')
    let displayAmount = this.displayAmountTarget
    let formAmount = this.formAmountTarget.value

    const formatter = new Intl.NumberFormat('en-US', { style: 'currency', currency: 'USD' })
    displayAmount = formatter.format(formAmount / 100.00)
    this.displayAmountTarget.innerText = displayAmount
  }


}
