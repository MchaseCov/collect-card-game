class AddTurnTimeToGames < ActiveRecord::Migration[7.0]
  def change
    add_column :games, :turn_time, :datetime
  end
end
