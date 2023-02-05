class CreateTrxes < ActiveRecord::Migration[7.0]
  def change
    create_table :trxes do |t|
      t.date :date, null: false
      t.integer :amount, null: false, default: 0
      t.string :memo
      t.references :account, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true
      t.references :vendor, null: false, foreign_key: true

      t.timestamps
    end
    add_index :trxes, :date
  end
end
