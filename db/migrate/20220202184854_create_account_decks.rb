class CreateAccountDecks < ActiveRecord::Migration[7.0]
  def change
    create_table :account_decks do |t|
      t.string :name
      t.references :user, null: false, foreign_key: true
      t.integer :card_count, default: 0
      t.references :archetype, null: false, foreign_key: true
      t.references :race, null: false, foreign_key: true

      t.timestamps
    end
  end
end
