class CreateAccounts < ActiveRecord::Migration[7.0]
  def change
    create_table :accounts do |t|
      t.string :name, null: false
      t.integer :balance, default: 0, null: false
      t.boolean :on_budget, null: false, default: true
      t.boolean :closed, null: false, default: false

      t.timestamps
    end
  end
end
