class CreateCards < ActiveRecord::Migration[7.0]
  def change
    create_table :cards do |t|
      t.integer :cost
      t.integer :health
      t.integer :attack
      t.integer :health_cap
      t.string :location
      t.string :status
      t.integer :position
      t.string :type
      t.references :gamestate_deck, null: false, foreign_key: true
      t.references :card_constant, null: false, foreign_key: true

      t.timestamps
    end
  end
end
