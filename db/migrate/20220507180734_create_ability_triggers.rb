class CreateAbilityTriggers < ActiveRecord::Migration[7.0]
  def change
    create_table :ability_triggers do |t|
      t.references :ability, null: false, foreign_key: true
      t.integer :trigger, default: 0
      t.integer :group, default: 0
      t.integer :alignment, default: 0
      t.integer :target_type, default: 0
      t.integer :additional_scoping, default: nil
      t.references :card_constant, null: false, foreign_key: true

      t.timestamps
    end
  end
end
