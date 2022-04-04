#=======================================|KEYWORD TABLE SCHEMA|=======================================
#
# table name: keywords
#
# id                      :bigint       null: false, primary key
# type                    :string       STI column
# player_choice           :boolean      default: false
# target                  :string       array of chain to target from card
# action                  :string
# modifier                :integer
# body text               :string
# card_constant_id        :integer      null: true, foreign key of PCP
#
class Keyword < ApplicationRecord
  include GenericKeywordActions
  include SpecifiedKeywordActions
  belongs_to :card_constant
  has_and_belongs_to_many :buffs
  validates_presence_of :type, :target, :card_constant_id
  validates :type, inclusion: { in: %w[Deathrattle Battlecry Cast Taunt Aura Listener] },
                   uniqueness: { scope: :card_constant_id }

  def buff
    buffs.first
  end

  %i[Battlecry Cast Deathrattle Taunt].each do |type|
    scope type.to_s.downcase, -> { find_by('type': type) }
  end

  def trigger(invoking_card, target_input)
    @invoking_card = invoking_card
    @target_input = target_input if target_input
    @targets = set_final_target
    method(action).call
  end

  # For use in stimulus controller
  def find_target_options(card)
    @invoking_card = card # Arbitrary
    target_data = find_valid_targets
    { ids: target_data.map(&:id) }
  end

  private

  def find_valid_targets
    target.inject(self, &:send)
  end

  def set_final_target
    player_choice ? find_valid_targets.find(@target_input) : find_valid_targets
  end

  attr_reader :invoking_card

  def player_of_card
    @invoking_card.player
  end

  def opposing_player_of_card
    game_of_card.opposing_player_of(player_of_card)
  end

  def game_of_card
    @invoking_card.game
  end
end
