#Create default vendors
Vendor.create!(name: "Starting balance")
Vendor.create!(name: "Budget")
Vendor.create!(name: "Manual Balance Adjustment")
Vendor.create!(name: "Vendor needed")
Vendor.create!(name: "Other")

Vendor.create!(name: "Grocery Store")
Vendor.create!(name: "Gas Station")
Vendor.create!(name: "Hardware Store")
Vendor.create!(name: "Fancy Restaurant")
Vendor.create!(name: "Food Truck")
Vendor.create!(name: "Doctor's Office")
Vendor.create!(name: "Office Supply Store")
Vendor.create!(name: "Sports Arena")

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

Account.create!( name: "ABC", starting_balance: 1039007, starting_date: Date.new(2022,10,20))
Account.create!( name: "XYZ", starting_balance: 456, starting_date: Date.new(2022,12,21))
Account.create!( name: "Retirement", starting_balance: 10000, starting_date: Date.new(2022,11,15), on_budget: false)
Account.create!( name: "cash", starting_balance: 100, starting_date: Date.new(2023,7,1))
Account.create!( name: "credit", starting_balance: 200, starting_date: Date.new(2023,1,2))
Account.create!( name: "Venmo", starting_balance: 300, starting_date: Date.new(2023,1,3))

