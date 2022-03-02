class AddColorToArchetypes < ActiveRecord::Migration[7.0]
  def change
    add_column :archetypes, :color, :string
  end
end
