class CreateGamestateDecks < ActiveRecord::Migration[7.0]
  def change
    create_table :gamestate_decks do |t|
      t.integer :card_count
      t.references :player, null: false, foreign_key: true
      t.references :game, null: false, foreign_key: true

      t.timestamps
    end
  end
end
