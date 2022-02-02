class CreateJoinTableAccountDecksPartyCardParents < ActiveRecord::Migration[7.0]
  def change
    create_join_table :account_decks, :party_card_parents do |t|
      t.index(%i[account_deck_id party_card_parent_id], name: 'index_account_deck_cards_on_id')
      # t.index [:party_card_parent_id, :account_deck_id]
    end
  end
end
