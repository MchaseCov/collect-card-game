class ConvertPlayerStatusToEnumInteger < ActiveRecord::Migration[7.0]
  def change
    remove_column :players, :status, :string
    add_column :players, :status, :integer, default: 0
    add_index :players, :status
  end
end
