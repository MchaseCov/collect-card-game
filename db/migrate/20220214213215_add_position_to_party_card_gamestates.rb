class AddPositionToPartyCardGamestates < ActiveRecord::Migration[7.0]
  def change
    add_column :party_card_gamestates, :position, :integer
  end
end
