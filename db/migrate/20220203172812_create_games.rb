class CreateGames < ActiveRecord::Migration[7.0]
  def change
    create_table :games do |t|
      t.boolean :turn, default: true
      t.boolean :ongoing, default: true
      t.references :winner, null: true, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
