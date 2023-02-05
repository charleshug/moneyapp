class CreateLines < ActiveRecord::Migration[7.0]
  def change
    create_table :lines do |t|
      t.integer :amount, null: false, default: 0
      t.string :memo
      t.references :trx, null: false, foreign_key: true
      t.references :category, null: false, foreign_key: true
      t.string :line_type, null: false

      t.timestamps
    end
    add_index :lines, :line_type
  end
end
