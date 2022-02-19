class CreateKeywords < ActiveRecord::Migration[7.0]
  def change
    create_table :keywords do |t|
      t.string :type
      t.boolean :player_choice, default: false
      t.string :target, array: true, default: []
      t.string :action
      t.integer :modifier
      t.references :party_card_parent, null: false, foreign_key: true

      t.timestamps
    end
  end
end
