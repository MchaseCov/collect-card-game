class CreateActiveBuffs < ActiveRecord::Migration[7.0]
  def change
    create_table :active_buffs do |t|
      t.references :buff, null: false, foreign_key: true, index: true
      t.references :buffable, polymorphic: true, index: true

      t.timestamps
    end
  end
end
