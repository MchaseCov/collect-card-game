#=======================================|PARTY CARD GAMESTATE TABLE SCHEMA|=======================================
#
# table name: party_card_gamestates
#
# id                      :bigint       null: false, primary key
# health_cap              :integer
# health_current          :integer
# cost_current            :integer
# attack_cap              :integer
# attack_current          :integer
# location                :string
# status                  :string
# archetype_id            :bigint       null: false, foreign key
# party_card_parent_id    :bigint       null: false, foreign key
# gamestate_deck_id       :bigint       null: false, foreign key
# timestamps              :datetime

class PartyCardGamestate < ApplicationRecord
  validates_presence_of :health_cap, :health_current, :cost_current, :attack_cap, :attack_current,
                        :location, :status
  validates_numericality_of :health_cap, :attack_cap
  validates :health_current, numericality: { less_than_or_equal_to: :health_cap }
  validates :cost_current, numericality: { in: 0..10 }
  validates :attack_current, numericality: { less_than_or_equal_to: :attack_cap }

  belongs_to :archetype
  belongs_to :party_card_parent
  belongs_to :gamestate_deck

  has_one :player, through: :gamestate_deck
  has_one :game, through: :gamestate_deck
end