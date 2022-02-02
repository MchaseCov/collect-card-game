class RenameGroupToArchetype < ActiveRecord::Migration[7.0]
  def change
    rename_column :party_card_parents, :group, :archetype
  end
end
