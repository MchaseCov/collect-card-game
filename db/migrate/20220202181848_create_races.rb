class CreateRaces < ActiveRecord::Migration[7.0]
  def change
    create_table :races do |t|
      t.string :name
      t.text :description
      t.integer :health_modifier
      t.integer :cost_modifier
      t.integer :resource_modifier

      t.timestamps
    end
  end
end
