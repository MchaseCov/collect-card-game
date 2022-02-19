#=======================================|KEYWORD TABLE SCHEMA|=======================================
#
# table name: keywords
#
# id                      :bigint       null: false, primary key
# type                    :string       STI column
# player_choice           :boolean      default: false
# target                  :string       array of chain to target from card
# modifier                :integer
# party_card_parent_id    :integer      null: true, foreign key of PCP
#
class Keyword < ApplicationRecord
  belongs_to :party_card_parent

  validates_presence_of :type, :player_choice, :target, :modifier
  validates_numericality_of :modifier
  validates :type, inclusion: { in: %w[Deathrattle Battlecry] }

  scope :deathrattle, -> { where(type: 'Deathrattle') }
  scope :battlecry, -> { where(type: 'Battlecry') }
end
