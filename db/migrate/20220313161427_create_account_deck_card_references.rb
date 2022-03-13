class CreateAccountDeckCardReferences < ActiveRecord::Migration[7.0]
  def change
    create_join_table :account_deck, :card_references do |t|
      t.index(%i[account_deck_id card_reference_id], name: 'index_account_deck_card_references_id')
      # t.index [:party_card_parent_id, :account_deck_id]
    end
  end
end
