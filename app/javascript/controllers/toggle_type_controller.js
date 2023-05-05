import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static classes = ["change"]
  static targets = ["incomeBox","expenseBox","displayAmount"]

  connect() {
    //console.log(this.incomeBoxTarget)
    //console.log('hi')
  }

  toggle() {
    //console.log(this.element)
    //console.log(this)
    //console.log(this.changeClass)
    //this.incomeBoxTarget.classList.toggle(this.changeClass)
    //this.element.classList.toggle(this.changeClass)
    
    console.log("event currentTarget:")
    console.log(event.currentTarget)
    //console.log("event currentTarget changeClass:")
    //console.log(event.currentTarget.changeClass)
    //console.log("event target dataset:")
    //console.log(event.currentTarget.dataset)
    //console.log(event.currentTarget.dataset.toggleTypeChangeClass) //works
    
    //let newClass = event.currentTarget.dataset.toggleTypeChangeClass
    event.currentTarget.classList.toggle(event.currentTarget.dataset.toggleTypeChangeClass)
    

    //this.element.classList.replace('bg-white', this.changeClass)

    //this.element.classList.toggle('hidden')
  }

  toggleIncome(){
    if ( event.currentTarget.classList.contains('text-white') ){
    } else {
      event.currentTarget.classList.add('text-white')
      event.currentTarget.classList.add('bg-green-500')
      event.currentTarget.classList.remove('text-black')
      event.currentTarget.classList.remove('bg-white')
      this.expenseBoxTarget.classList.add('text-black')
      this.expenseBoxTarget.classList.add('bg-white')
      this.expenseBoxTarget.classList.remove('text-white')
      this.expenseBoxTarget.classList.remove('bg-red-500')

      this.displayAmountTarget.classList.toggle('text-green-500')
      this.displayAmountTarget.classList.toggle('text-red-500')

      let displayAmount = document.querySelector('#displayAmount')
      let trx_amount = document.querySelector('#trx_amount')
      if (trx_amount.value < 0) {
        trx_amount.value = -trx_amount.value
        displayAmount.innerHTML = displayAmount.innerHTML.replace("-", "")
      }
    }
  }

  toggleExpense() {
    if (event.currentTarget.classList.contains('text-white')) {
    } else {
      event.currentTarget.classList.add('text-white')
      event.currentTarget.classList.add('bg-red-500')
      event.currentTarget.classList.remove('text-black')
      event.currentTarget.classList.remove('bg-white')
      this.incomeBoxTarget.classList.add('text-black')
      this.incomeBoxTarget.classList.add('bg-white')
      this.incomeBoxTarget.classList.remove('text-white')
      this.incomeBoxTarget.classList.remove('bg-green-500')

      this.displayAmountTarget.classList.toggle('text-green-500')
      this.displayAmountTarget.classList.toggle('text-red-500')

      let displayAmount = document.querySelector('#displayAmount')
      let trx_amount = document.querySelector('#trx_amount')
      if (trx_amount.value > 0) {
        trx_amount.value = -trx_amount.value
        displayAmount.innerHTML = "-" + displayAmount.innerHTML
      }
    }
  }
}