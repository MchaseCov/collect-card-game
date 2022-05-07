class CreateAbilityTriggers < ActiveRecord::Migration[7.0]
  def change
    create_table :ability_triggers do |t|
      t.references :ability, null: false, foreign_key: true
      t.integer :ability_type, default: 0
      t.integer :ability_trigger, default: 0
      t.integer :ability_group, default: 0
      t.integer :ability_alignment, default: 0
      t.integer :ability_target_type, default: 0

      t.timestamps
    end
  end
end
