class AddPrimaryKeyToAccountDecksPartyCardParents < ActiveRecord::Migration[7.0]
  def change
    rename_table 'account_decks_party_card_parents', 'account_deck_party_card_parents'
    add_column :account_deck_party_card_parents, :id, :primary_key
  end
end
