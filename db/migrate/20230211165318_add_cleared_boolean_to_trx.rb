class AddClearedBooleanToTrx < ActiveRecord::Migration[7.0]
  def change
    add_column :trxes, :cleared, :boolean, null: false, default: false
  end
  add_index :trxes, :cleared
end
