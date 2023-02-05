module ApplicationHelper

  def full_title(page_title= '')
    base_title = "MoneyApp"
    if page_title.empty?
      base_title
    else
      page_title + " | " + base_title
    end
  end

  def presentableNum(amount)
    number_to_currency(amount/100.00, unit:"", delimiter: ",")
  end  
  
  def presentableNumDollar(amount)
    number_to_currency(amount/100.00, delimiter: ",")
  end 
  
end
