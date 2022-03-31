class CreateCardGameListeners < ActiveRecord::Migration[7.0]
  def change
    create_table :active_listener_cards do |t|
      t.references :active_listener, null: false, foreign_key: true
      t.references :card, null: false, foreign_key: true

      t.timestamps
    end
  end
end
