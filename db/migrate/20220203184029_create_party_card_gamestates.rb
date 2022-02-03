class CreatePartyCardGamestates < ActiveRecord::Migration[7.0]
  def change
    create_table :party_card_gamestates do |t|
      t.integer :health_cap
      t.integer :health_current
      t.integer :cost_current
      t.integer :attack_cap
      t.integer :attack_current
      t.string :location
      t.string :status
      t.references :archetype, null: false, foreign_key: true
      t.references :party_card_parent, null: false, foreign_key: true
      t.references :gamestate_deck, null: false, foreign_key: true

      t.timestamps
    end
  end
end
