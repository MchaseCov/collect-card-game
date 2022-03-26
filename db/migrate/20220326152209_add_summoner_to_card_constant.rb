class AddSummonerToCardConstant < ActiveRecord::Migration[7.0]
  def change
    add_reference :card_constants, :summoner, foreign_key: { to_table: :card_constants }
  end
end
