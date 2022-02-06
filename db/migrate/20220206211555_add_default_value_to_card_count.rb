class AddDefaultValueToCardCount < ActiveRecord::Migration[7.0]
  def change
    change_column :account_decks, :card_count, :integer, default: 0
  end
end
