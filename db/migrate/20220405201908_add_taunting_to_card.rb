class AddTauntingToCard < ActiveRecord::Migration[7.0]
  def change
    add_column :cards, :taunting, :boolean, default: false
  end
end
