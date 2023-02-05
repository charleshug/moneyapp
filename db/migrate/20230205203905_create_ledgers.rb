class CreateLedgers < ActiveRecord::Migration[7.0]
  def change
    create_table :ledgers do |t|
      t.date :date, null: false
      t.boolean :carry_forward_negative_balance, default: false
      t.integer :beginning_balance, default: 0
      t.integer :budget, default: 0
      t.integer :actual, default: 0
      t.integer :net, default: 0
      t.integer :end_balance, default: 0
      t.integer :carried_balance, default: 0
      t.references :category, null: false, foreign_key: true

      t.index [:date, :category_id], unique: true

      t.timestamps
    end
    add_index :ledgers, :date
  end
end
