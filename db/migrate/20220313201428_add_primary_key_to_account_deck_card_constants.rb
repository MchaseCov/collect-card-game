class AddPrimaryKeyToAccountDeckCardConstants < ActiveRecord::Migration[7.0]
  def change
    add_column :account_deck_card_references, :id, :primary_key
  end
end
