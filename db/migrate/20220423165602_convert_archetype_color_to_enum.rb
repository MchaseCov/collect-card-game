class ConvertArchetypeColorToEnum < ActiveRecord::Migration[7.0]
  def change
    remove_column :archetypes, :color, :string
    add_column :archetypes, :color, :integer, default: 0
  end
end
