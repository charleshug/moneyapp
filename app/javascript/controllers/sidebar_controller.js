import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["home", "bar", "budgets", "title1", "title2", "title3",
   "title4", "title5", "title6",
    "budgetList", "budgetListArrow" ]

  connect() {
    //console.log("Hello, sidebar!", this.element)
    //this.barTarget.classList.add("lg:w-80")
  }

  toggle() {
    //this.homeTarget.classList.toggle("rotate-90")
    // this.barTarget.classList.toggle("sm:w-80")
    // this.barTarget.classList.toggle("w-full")
    // this.budgetsTarget.classList.toggle("hidden")
    // this.title1Target.classList.toggle("hidden")
    // this.title2Target.classList.toggle("hidden")
    // this.title3Target.classList.toggle("hidden")
    // this.title4Target.classList.toggle("hidden")
    // this.title5Target.classList.toggle("hidden")
  }

  toggle_budgetList(){
    this.budgetListArrowTarget.classList.toggle("rotate-90")
    this.budgetListTarget.classList.toggle("hidden")
  }

}
