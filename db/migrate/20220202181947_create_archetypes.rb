class CreateArchetypes < ActiveRecord::Migration[7.0]
  def change
    create_table :archetypes do |t|
      t.string :name
      t.text :description
      t.string :resource_type
      t.string :color

      t.timestamps
    end
  end
end
