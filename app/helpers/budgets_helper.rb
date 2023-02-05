module BudgetsHelper
  
  def getCategoryBalanceOn(category,date)
    l = Ledger.find_by(category: category, date: date.beginning_of_month)&.end_balance || 0
  end

  def getBalanceAtDate(categoryName, date)
    Ledger.find_by(category: Category.find_by(name: categoryName), date: date.beginning_of_month)&.end_balance || 0
  end

  def getCumulativeOverspentThru(date)
    Ledger.where(date: date)
          .where("end_balance < 0")
          .where(carry_forward_negative_balance: false)
          .sum(:end_balance)
  end

  def getCategoryCumulativeOverspentThru(category, date)
    
    Ledger.find_by(category: category, date: date.beginning_of_month)&.carried_balance || 0
  end

  def getOverspentOn(date)

    Ledger.where(date: date.beginning_of_month)
          .where(carry_forward_negative_balance: false)
          .where('end_balance < 0')&.sum(:end_balance)
  end



  def getBudgetData(date)
    date = date.beginning_of_month
    parent_categories = Category.top_level.budget.includes(:subcategories)
    year = date.year
    month= date.month
    prevDate = date << 1
    prevPrevMonthEnd = (date << 1) -1
    prevYear = prevDate.year
    prevMonth = prevDate.month


    data = { year => {} }

      prevIncome_cumulative = Line.date_thru(prevDate.end_of_month).on_budget.where(category_id: Category.income).sum(:amount) + Trx.date_thru(prevDate.end_of_month).on_budget_accounts.where(category_id: Category.income).sum(:amount)
      prevBudget_cumulative = Trx.date_thru(prevDate.end_of_month).on_budget_accounts.budgetItems.sum(:amount)
      prevOverspent_cumulative = Ledger.date_thru(prevDate-1).negative_end_balance.not_carry_forward_negative.sum(:end_balance)
      prevAvailable = prevIncome_cumulative - prevBudget_cumulative + prevOverspent_cumulative
      prevOverspent = getOverspentOn(date << 1)
      currIncome    = Line.period(date).on_budget.where(category_id: Category.income).sum(:amount) + Trx.period(date).on_budget_accounts.where(category_id: Category.income).sum(:amount)
      currBudget  = Trx.period(date).on_budget_accounts.budgetItems.sum(:amount)
      #currBudget  = Trx.period(date.strftime("%Y-%m")).on_budget_accounts.budgetItems.sum(:amount)
      currAvailable = prevAvailable + prevOverspent + currIncome - currBudget

      data[year][month]= { dashboard: { prevAvailable: prevAvailable,
                                        prevOverspent: prevOverspent,
                                        currIncome:    currIncome,
                                        currBudget:  currBudget,
                                        currAvailable: currAvailable } }
      
      data[year][month][:total]= { budget: 0,
                                    actual: 0,
                                    net:    0, 
                                    balance: 0 }


      data[year][month][:parents]={}
      parent_categories.each do |parent|
        
        data[year][month][:parents][parent.name]={total: { budget: 0,
                                                      actual: 0,
                                                      net: 0,
                                                      balance: 0 } }

        data[year][month][:parents][parent.name][:subcategories]={}
        parent.subcategories.not_hidden
                       .budget
                       .each do |subcategory|
          #-----------------------------------------------------------------
          ledger  = Ledger.find_by(category: subcategory, date: date.beginning_of_month)

          budget  = ledger&.budget || 0
          actual  = ledger&.actual || 0
          net     = ledger&.net    || 0
          balance = ledger&.end_balance || 0

          if ledger.nil? 
            prevLedger = Ledger.closest_previous(date,subcategory)
            balance = prevLedger&.carried_balance || 0
          end
                    
          #-----------------------------------------------------------------
          data[year][month][:parents][parent.name][:subcategories][subcategory.name]={ budget: budget,
                                                                        actual: actual,
                                                                        net: net,
                                                                        balance: balance }
          #calculate the parent totals from the built subcategories
          data[year][month][:parents][parent.name][:total][:budget] += budget
          data[year][month][:parents][parent.name][:total][:actual] += actual
          data[year][month][:parents][parent.name][:total][:net] += net
          data[year][month][:parents][parent.name][:total][:balance] += balance
        end

        #calculate the period totals from the built parent categories
        data[year][month][:total][:budget]  += data[year][month][:parents][parent.name][:total][:budget]
        data[year][month][:total][:actual]  += data[year][month][:parents][parent.name][:total][:actual]
        data[year][month][:total][:net]     += data[year][month][:parents][parent.name][:total][:net]
        data[year][month][:total][:balance] += data[year][month][:parents][parent.name][:total][:balance]
        
      end
    return data
  end

end