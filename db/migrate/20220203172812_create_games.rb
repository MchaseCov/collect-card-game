class CreateGames < ActiveRecord::Migration[7.0]
  def change
    create_table :games do |t|
      t.boolean :turn, default: true
      t.boolean :ongoing, default: true
      t.string :status, default: 'mulligan'
      t.datetime :turn_time
      t.timestamps
    end
  end
end
