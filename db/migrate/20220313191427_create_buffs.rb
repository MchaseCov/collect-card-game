class CreateBuffs < ActiveRecord::Migration[7.0]
  def change
    create_table :buffs do |t|
      t.string :name
      t.string :target_method
      t.string :removal_method
      t.integer :modifier
      t.references :keyword, null: true, foreign_key: true, optional: true

      t.timestamps
    end
  end
end
