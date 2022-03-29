#=======================================|CARD CONSTANT TABLE SCHEMA|=======================================
#
# table name: card_constants
#
# id                      :bigint       null: false, primary key
# name                    :string
# tribe                   :string
# archetype_id            :bigint       null: false, foreign key of archetype
# summoner_id             :bigint       optional, FK of card_constant for token summoner
# timestamps              :datetime
#

class CardConstant < ApplicationRecord
  validates_presence_of :name
  validates_uniqueness_of :name
  validates :summoner_id, presence: true, uniqueness: true, allow_blank: true, if: -> { archetype.name == 'Token' }

  belongs_to :archetype
  has_many :keywords, class_name: :Keyword,
                      foreign_key: :card_constant_id,
                      inverse_of: :card_constant,
                      dependent: :destroy
  belongs_to :summoner, class_name: :CardConstant,
                        optional: true,
                        foreign_key: :summoner_id,
                        inverse_of: :token
  has_one :token, class_name: :CardConstant,
                  foreign_key: :summoner_id,
                  inverse_of: :summoner

  has_one :card_reference, dependent: :destroy
  has_many :cards, dependent: :destroy

  has_one :battlecry, -> { where(type: 'Battlecry') }, class_name: :Keyword,
                                                       foreign_key: :card_constant_id,
                                                       inverse_of: :card_constant

  has_one :cast_effect, -> { where(type: 'Cast') }, class_name: :Keyword,
                                                    foreign_key: :card_constant_id,
                                                    inverse_of: :card_constant
  has_one :taunt, -> { where(type: 'Taunt') }, class_name: :Keyword,
                                               foreign_key: :card_constant_id,
                                               inverse_of: :card_constant
  has_one :aura, -> { where(type: 'Aura') }, class_name: :Keyword,
                                             foreign_key: :card_constant_id,
                                             inverse_of: :card_constant
  has_one :ai_decision_datum

  %i[Beast Humanoid].each do |tribe|
    scope "#{tribe.downcase}_tribe".to_sym, -> { where(tribe: tribe) }
  end
end
