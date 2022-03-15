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
  belongs_to :card_constant
  has_one :buff

  validates_presence_of :type, :target, :card_constant_id
  validates :type, inclusion: { in: %w[Deathrattle Battlecry Cast] },
                   uniqueness: { scope: :card_constant_id }

  def trigger(invoking_card, target_input)
    @invoking_card = invoking_card
    @target_input = target_input if target_input
    set_final_target.each { |c| c.buffs << buff } and return if buff

    set_final_target.each { |t| t.method(action).call(modifier) }
  end

  # For use in stimulus controller
  def find_target_options(game)
    @invoking_card = game.current_player.cards.in_hand.first # Arbitrary
    target_data = find_valid_targets
    { ids: target_data.map(&:id) }
  end

  private

  def find_valid_targets
    evaluated_target = self
    target.each do |target_scope|
      evaluated_target = evaluated_target.send(target_scope)
    end
    evaluated_target
  end

  def set_final_target
    valid_targets = find_valid_targets
    return [valid_targets.find(@target_input)] if player_choice

    [valid_targets].flatten
  end

  def player_of_card
    @invoking_card.player
  end

  def opposing_player_of_card
    @invoking_card.game.opposing_player_of(player_of_card)
  end
end
