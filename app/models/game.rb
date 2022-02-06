#=======================================|GAME TABLE SCHEMA|=======================================
#
# table name: games
#
# id                      :bigint       null: false, primary key
# turn                    :boolean      default: true
# ongoing                 :boolean      default: true
# winner_id               :integer      null: true, foreign key of user
#

class Game < ApplicationRecord
  #=======================================|GAME CALLBACKS|==========================================
  after_create_commit do
    # Things
  end

  #=======================================|GAME ASSOCIATIONS|=======================================

  has_one :player_one, -> { where('turn_order = true') },
          class_name: :Player,
          foreign_key: :game_id,
          inverse_of: :game

  has_one :player_two, -> { where('turn_order = false') },
          class_name: :Player,
          foreign_key: :game_id,
          inverse_of: :game

  has_one :current_player, -> { where('turn_order = ?', turn) },
          class_name: :Player,
          foreign_key: :game_id,
          inverse_of: :game

  belongs_to :winner, optional: true

  #=======================================|GAME METHODS|=====================================
end
