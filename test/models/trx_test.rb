require "test_helper"

class TrxTest < ActiveSupport::TestCase
  test "creating Trx updates associated Account balance" do
    c = Category.create!(name: "test_category")
    v = Vendor.create!(name: "test_vendor")
    a = Account.create!(name: "first_account", balance: 0 )

    t = Trx.create!(date: Date.today, amount: 100, category: c, account: a, vendor: v )

    t.save!
    assert_equal 100, a.reload.balance, "Balance should be increased by 100"

    t2 = Trx.create!(date: Date.today, amount: -50, category: c, account: a, vendor: v )
    assert_equal 50, a.reload.balance, "Balance should be decreased by 50"
  end

  test "changing Trx account, updates associated Account balances" do
    c = Category.create!(name: "test_category")
    v = Vendor.create!(name: "test_vendor")
    a1 = Account.create!(name: "first_account", balance: 0 )
    a2 = Account.create!(name: "second_account", balance: 0 )

    t = Trx.create!(date: Date.today, amount: 100, category: c, account: a1, vendor: v )
    t.save!
    assert_equal 100, a1.reload.balance, "#{a1.name} balance should be increased by 100"
    assert_equal 0, a2.reload.balance, "#{a2.name} balance should be unchanged"

    t.account = a2
    t.save!
    assert_equal 0, a1.reload.balance, "#{a1.name} balance should be decreased to 0"
    assert_equal 100, a2.reload.balance, "#{a2.name} balance should be increased to 100"

  end
end
