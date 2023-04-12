class AddPositionToAccount < ActiveRecord::Migration[7.0]
  def change
    add_column :accounts, :position, :integer
    Account.order(:updated_at).each.with_index(1) do |account, index|
      account.update_column :position, index
    end
    add_index :accounts, :position
  end
end
