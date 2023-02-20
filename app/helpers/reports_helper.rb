module ReportsHelper

  def get_net_worth_for_new_worth_report
    #builds a hash of Period => Sum, then .maps so each month represents the rolling balance, then reduces it from hash to array
    sum=0
    Trx.registerItems
        .group_by_month(:date, format: '%b %Y')
        .sum(:amount)
        .map { |x,y| { x => (sum += y/100.0).round(2) } }
        .reduce({}, :merge)
  end

  def get_category_amount_for_spending_report
    categories = Category.joins(subcategories: :trxes)
      .merge(Trx.registerItems.nonIncome)
      .group(:name)
      .sum(:amount)
      .sort_by { |k,v| v }
      
      convert_hash_integer_value_to_float(categories)
  end

  def get_vendors_for_spending_report
    vendors = Vendor.joins(:trxes)
                    .merge(Trx.registerItems.nonIncome)
                    .group(:name)
                    .sum(:amount)
    vendors = consolidate_small_vendors_hash(vendors)
    convert_hash_integer_value_to_float(vendors)
      #.sort_by { |k,v| v }
      #.map { |x,y| { x => (y/100.0).round(2) } }
      #.reduce({}, :merge)
      #.to_h
  end

  def consolidate_small_vendors_hash(input)
    percentage = 0.02  #vendors less than this percent of total will be grouped
    hash_total = input.values.reduce(:+)
    consolidated_sum = 0
    new_hash = {}
    input.each do |k,v|
      calculated_percent = ((v * 1.0) / hash_total).round(3)
      if( calculated_percent.abs < percentage )
        consolidated_sum += v
      else
        new_hash[k] = v
      end
    end
    new_hash = new_hash.sort_by {|k,v| v}.to_h
    new_hash["All Other Vendors"] = consolidated_sum
    new_hash
  end

  def convert_hash_integer_value_to_float(input)
      input.map { |x,y| { x => (y/100.0).round(2) } }
           .reduce({}, :merge)
  end

  
end
