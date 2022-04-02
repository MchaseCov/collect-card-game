class ConvertStatusLocationToString < ActiveRecord::Migration[7.0]
  def change
    remove_column :cards, :status, :string
    remove_column :cards, :location, :string
    add_column :cards, :status, :integer, default: 0
    add_column :cards, :location, :integer, default: 0
    add_index :cards, :status
    add_index :cards, :location
    add_index :cards, :type
  end
end
