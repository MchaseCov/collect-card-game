class CreateCardReferences < ActiveRecord::Migration[7.0]
  def change
    create_table :card_references do |t|
      t.integer :cost
      t.integer :attack
      t.integer :health
      t.string :card_type
      t.references :card_constant, null: false, foreign_key: true

      t.timestamps
    end
  end
end
