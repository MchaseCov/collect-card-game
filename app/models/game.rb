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
  belongs_to :winner, optional: true
end
