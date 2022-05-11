class ChangeColumnNmaesOfAbilityTrigger < ActiveRecord::Migration[7.0]
  def change
    rename_column :ability_triggers, :group, :target_scope
    add_index :ability_triggers, :trigger
  end
end
