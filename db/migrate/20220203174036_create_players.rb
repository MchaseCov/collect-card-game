class CreatePlayers < ActiveRecord::Migration[7.0]
  def change
    create_table :players do |t|
      t.integer :health_cap
      t.integer :health_current
      t.integer :cost_cap
      t.integer :cost_current
      t.integer :resource_cap
      t.integer :resource_current
      t.boolean :turn_order
      t.integer :attack, default: 0
      t.string :status, default: 'default'
      t.references :race, null: false, foreign_key: true
      t.references :archetype, null: false, foreign_key: true
      t.references :game, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
