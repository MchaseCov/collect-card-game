class CreateGameListeners < ActiveRecord::Migration[7.0]
  def change
    create_table :active_listeners do |t|
      t.references :keyword, null: true, foreign_key: true
      t.references :card, null: false, foreign_key: true

      t.timestamps
    end
  end
end
