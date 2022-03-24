#=======================================|CARD CONSTANT TABLE SCHEMA|=======================================
#
# table name: card_constants
#
# id                      :bigint       null: false, primary key
# name                    :string
# tribe                   :string
# archetype_id            :sbigint      null: false, foreign key of archetype
# timestamps              :datetime
#

class CardConstant < ApplicationRecord
  validates_presence_of :name
  validates_uniqueness_of :name

  belongs_to :archetype
  has_many :keywords, class_name: :Keyword,
                      foreign_key: :card_constant_id,
                      inverse_of: :card_constant,
                      dependent: :destroy

  has_one :battlecry, -> { where(type: 'Battlecry') }, class_name: :Keyword,
                                                       foreign_key: :card_constant_id,
                                                       inverse_of: :card_constant

  has_one :cast_effect, -> { where(type: 'Cast') }, class_name: :Keyword,
                                                    foreign_key: :card_constant_id,
                                                    inverse_of: :card_constant
  has_one :ai_decision_datum

  %i[Beast Humanoid].each do |tribe|
    scope "#{tribe.downcase}_tribe".to_sym, -> { where(tribe: tribe) }
  end
end
