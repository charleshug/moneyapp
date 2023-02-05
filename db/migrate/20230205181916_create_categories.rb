class CreateCategories < ActiveRecord::Migration[7.0]
  def change
    create_table :categories do |t|
      t.string :name, null: false
      t.integer :parent_id
      t.boolean :hidden, default: false

      t.timestamps
    end
    add_index :categories, :name
    add_index :categories, :parent_id
    add_index :categories, :hidden
  end
end
