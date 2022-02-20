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
# party_card_parent_id    :integer      null: true, foreign key of PCP
#
class Keyword < ApplicationRecord
  belongs_to :party_card_parent

  validates_presence_of :type, :target, :modifier, :party_card_parent_id
  validates_numericality_of :modifier
  validates :type, inclusion: { in: %w[Deathrattle Battlecry] },
                   uniqueness: { scope: :party_card_parent_id }

  def trigger(invoking_card, target_input)
    final_target = if player_choice
                     find_target(invoking_card, target_input)
                   else
                     evaluate_target_chain(invoking_card)
                   end
    final_target&.send(action, modifier)
  end

  private

  def evaluate_target_chain(inital_target)
    current_target = inital_target
    target.each do |target_step|
      call_and_params = target_step.split(',')
      current_target = current_target.send(*call_and_params)
    end
    current_target
  end

  def find_target(invoking_card, target_input)
    target_family = find_target_family(invoking_card)
    target_family.find(target_input)
  end

  # Add to case statement when adding a new "type" of target, like friendy deck or enemy hero!
  def find_target_family(invoking_card)
    case target[0]
    when 'friendly_battle' then invoking_card.player.cards.in_battle
    end
  end
end
