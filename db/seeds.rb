#Create default vendors

vendor_list = [ "Budget",
  "Starting balance",
  "Manual Balance Adjustment",
  "Vendor needed",
  "Other",
  "Grocery Store",
  "Gas Station",
  "Hardware Store",
  "Fancy Restaurant",
  "Food Truck",
  "Doctor's Office",
  "Office Supply Store",
  "Sports Arena"
]
vendor_list.each do |vendor|
  Vendor.create!(name: vendor)
end
vendorBudget = Vendor.find_by(name: "Budget")

# categories_list = {
#   'Income Parent': [
#     "Available next month",
#     "Available this month",
#     "Income",
#   ],
#   #???How to include hidden: true???
#   'Other': [
#     "Uncategorized",
#     "Split",
#     "N/A - No category needed",
#     "N/A - Off-Budget",
#   ],
#   '1. Everyday Expenses': [
#     "Fuel",
#     "Groceries",
#     "Restaurants",
#     "Entertainment",
#     "Household & Cleaning",
#     "Clothing",
#     "MISC",
#   ],
#   '2. Monthly Expenses': [
#     "Phone",
#     "Rent",
#     "Internet & Utilities",
#     "News Subscriptions",
#     "Car Registration",
#     "Car Insurance",
#     "Retirement-ROTH",
#     "Utilities",
#     "IRA payroll deduction",
#   ],
#   '3. Irregular Expenses': [
#     "Gen. Investment",
#     "Taxes",
#   ],
#   '4. Sinking Funds': [
#     "Medical/Dental",
#     "Computer Stuff",
#     "Gifts",
#     "Vacation",
#     "Car Repairs & Maint",
#     "New Phone Fund",
#   ],
#   'Emergency Funds': [
#     "Emergency Fund - liquid",
#   ]
# }
# categories_list.each do |parent, subcategories|
#   temp_parent = Category.create!(name: parent)
#   subcategories.each do |sub|
#     Category.create!(name: sub, parent: temp_parent)
#   end
# end

#Create default categories
parentCat_Income        = Category.create( name: "Income Parent" )
parentCat_Other         = Category.create( name: "Other",  hidden: true  )
parentCat_Everyday      = Category.create( name: "1. Everyday Expenses" )
parentCat_Monthly       = Category.create( name: "2. Monthly Expenses" )
parentCat_Irregular     = Category.create( name: "3. Irregular Expenses" )
parentCat_Sinking       = Category.create( name: "4. Sinking Funds" )
parentCat_Emergency     = Category.create( name: "Emergency Funds" )

Category.create!([
  { name: "Available next month",      parent: parentCat_Income },
  { name: "Available this month",      parent: parentCat_Income },
  { name: "Income",                    parent: parentCat_Income },

  { name: "Uncategorized",             parent: parentCat_Other },
  { name: "Split",                     parent: parentCat_Other },
  { name: "N/A - No category needed",  parent: parentCat_Other },
  { name: "N/A - Off-Budget",          parent: parentCat_Other },

  { name: "Fuel",                      parent: parentCat_Everyday },
  { name: "Groceries",                 parent: parentCat_Everyday },
  { name: "Restaurants",               parent: parentCat_Everyday },
  { name: "Entertainment",             parent: parentCat_Everyday },
  { name: "Household & Cleaning",      parent: parentCat_Everyday },
  { name: "Clothing",                  parent: parentCat_Everyday },
  { name: "MISC",                      parent: parentCat_Everyday },

  { name: "Phone",                     parent: parentCat_Monthly },
  { name: "Rent",                      parent: parentCat_Monthly },
  { name: "Internet & Utilities",      parent: parentCat_Monthly },
  { name: "News Subscriptions",        parent: parentCat_Monthly },
  { name: "Car Registration",          parent: parentCat_Monthly },
  { name: "Car Insurance",             parent: parentCat_Monthly },
  { name: "Retirement-ROTH",           parent: parentCat_Monthly },
  { name: "Utilities",                 parent: parentCat_Monthly, hidden: true },
  { name: "IRA payroll deduction",     parent: parentCat_Monthly },

  { name: "Gen. Investment",           parent: parentCat_Irregular },
  { name: "Taxes",                     parent: parentCat_Irregular },

  { name: "Medical/Dental",            parent: parentCat_Sinking },
  { name: "Computer Stuff",            parent: parentCat_Sinking },
  { name: "Gifts",                     parent: parentCat_Sinking },
  { name: "Vacation",                  parent: parentCat_Sinking },
  { name: "Car Repairs & Maint",       parent: parentCat_Sinking },
  { name: "New Phone Fund",            parent: parentCat_Sinking },

  { name: "Emergency Fund - liquid",   parent: parentCat_Emergency }
])

# account_list = [
#   { name: "ABC",        starting_balance: 1039007, starting_date: Date.new(2022,10,20) },
#   { name: "XYZ",        starting_balance: 456,     starting_date: Date.new(2022,12,21) },
#   { name: "Retirement", starting_balance: 10000,   starting_date: Date.new(2022,11,15), on_budget: false },
#   { name: "cash",       starting_balance: 100,     starting_date: Date.new(2023,7,1) },
#   { name: "credit",     starting_balance: 200,     starting_date: Date.new(2023,1,2) },
#   { name: "Venmo",      starting_balance: 300,     starting_date: Date.new(2023,1,3) },
#   { name: "Budget", closed: true }
# ]
# account_list.each do |account|
#   Account.create!(account)
# end
# bankBudget = Account.find_by(name: "Budget")

Account.create!( name: "ABC", starting_balance: 1039007, starting_date: Date.new(2022,10,20))
Account.create!( name: "XYZ", starting_balance: 456, starting_date: Date.new(2022,12,21))
Account.create!( name: "Retirement", starting_balance: 10000, starting_date: Date.new(2022,11,15), on_budget: false)
Account.create!( name: "cash", starting_balance: 100, starting_date: Date.new(2023,7,1))
Account.create!( name: "credit", starting_balance: 200, starting_date: Date.new(2023,1,2))
Account.create!( name: "Venmo", starting_balance: 300, starting_date: Date.new(2023,1,3))
bankBudget = Account.create!( name: "Budget", closed: true )


budgetItems = [
  { date: "2022-12-01",
    lines: [ { amount: 6000,    category: 'Fuel' },
             { amount: 12000,   category: 'Groceries' },
             { amount: 12000,   category: 'Restaurants' },
             { amount: 20000,   category: 'Entertainment' },
             { amount: 5000,    category: 'Household & Cleaning' },
             { amount: 20000,   category: 'MISC' },
             { amount: 3500,    category: 'Phone'},
             { amount: 125000,  category: 'Rent'},
             { amount: 2300,    category: 'News Subscriptions'},
             { amount: 5000,    category: 'Car Repairs & Maint'},
             { amount: 1700,    category: 'Car Registration'},
             { amount: 883,     category: 'Car Insurance'},
             { amount: 50000,   category: 'Retirement-ROTH'},
             { amount: 2040,    category: 'Medical/Dental'},
             { amount: 80000,   category: 'Computer Stuff'}
            ]},
  { date: "2023-01-01",
    lines: [ { amount: 14912,   category: 'Fuel' },
             { amount: 21047,   category: 'Groceries' },
             { amount: 17887,   category: 'Restaurants' },
             { amount: 4017,    category: 'Entertainment' },
             { amount: 2089,    category: 'Household & Cleaning' },
             { amount: 12982,   category: 'MISC' },
             { amount: 3500,    category: 'Phone'},
             { amount: 125000,  category: 'Rent'},
             { amount: 2300,    category: 'News Subscriptions'},
             { amount: 1700,    category: 'Car Registration'},
             { amount: 36944,   category: 'Car Insurance'},
             { amount: 50000,   category: 'Retirement-ROTH'},
             { amount: 2041,    category: 'Medical/Dental'},
             { amount: 5000,    category: 'Car Repairs & Maint'},
            ]},
    { date: "2023-02-01",
    lines: [ { amount: 6000,   category: 'Fuel' },
             { amount: 12000,  category: 'Groceries' },
             { amount: 12000,  category: 'Restaurants' },
             { amount: 20000,  category: 'Entertainment' },
             { amount: 5000,   category: 'Household & Cleaning' },
             { amount: 793584, category: 'MISC' },
             { amount: 3500,   category: 'Phone'},
             { amount: 125000, category: 'Rent'},
             { amount: 6000,   category: 'Internet & Utilities'},
             { amount: 2300,   category: 'News Subscriptions'},
             { amount: 1700,   category: 'Car Registration'},
             { amount: 883,    category: 'Car Insurance'},
             { amount: 50000,  category: 'Retirement-ROTH'},
             { amount: 2040,   category: 'Medical/Dental'},
             { amount: 5000,   category: 'Car Repairs & Maint'},
            ]}
]

budgetItems.each_with_index do |i,index|
  t = Trx.new(
    date: i[:date],
    memo: "Budget",
    category: Category.find_by(name: "Split"),
    vendor: vendorBudget,
    account: bankBudget
  )

  i[:lines].each_with_index do |l|
    t.lines.build(
      line_type: "Budget",
      amount: l[:amount],
      category: Category.find_by(name: l[:category])
    )
  end
  t.save!
end