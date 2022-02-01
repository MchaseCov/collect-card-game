class CreatePartyCardParents < ActiveRecord::Migration[7.0]
  def change
    create_table :party_card_parents do |t|
      t.string :name
      t.integer :cost_default
      t.integer :attack_default
      t.integer :health_default
      t.string :tribe
      t.string :group
      t.text :body

      t.timestamps
    end
  end
end
