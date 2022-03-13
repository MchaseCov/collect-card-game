class CreateCardConstants < ActiveRecord::Migration[7.0]
  def change
    create_table :card_constants do |t|
      t.string :tribe
      t.references :archetype, null: false, foreign_key: true
      t.string :name

      t.timestamps
    end
  end
end
