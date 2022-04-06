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
                      dependent: :destroy do
                        %i[battlecry taunt deathrattle aura listener cast_effect].each do |keyword_type|
                          define_method(keyword_type) { find_by(type: keyword_type.to_s.upcase_first) }
                        end
                      end
  belongs_to :summoner, class_name: :CardConstant,
                        optional: true,
                        foreign_key: :summoner_id,
                        inverse_of: :token
  has_one :token, class_name: :CardConstant,
                  foreign_key: :summoner_id,
                  inverse_of: :summoner

  has_one :card_reference, dependent: :destroy
  has_many :cards, dependent: :destroy
  %i[battlecry taunt deathrattle aura listener cast_effect].each do |keyword_type|
    define_method(keyword_type) { keywords.send(keyword_type) }
  end
  has_one :ai_decision_datum

  %i[Beast Humanoid].each do |tribe|
    scope "#{tribe.downcase}_tribe".to_sym, -> { where(tribe: tribe) }
  end
end
