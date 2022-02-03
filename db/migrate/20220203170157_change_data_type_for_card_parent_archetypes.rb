class ChangeDataTypeForCardParentArchetypes < ActiveRecord::Migration[7.0]
  def change
    remove_column :party_card_parents, :archetype, :string
    add_reference :party_card_parents, :archetype, foreign_key: true
  end
end
