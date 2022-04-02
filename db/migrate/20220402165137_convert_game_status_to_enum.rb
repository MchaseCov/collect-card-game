class ConvertGameStatusToEnum < ActiveRecord::Migration[7.0]
  def change
    remove_column :games, :status, :string
    add_column :games, :status, :integer, default: 0
    add_index :games, :status
  end
end
