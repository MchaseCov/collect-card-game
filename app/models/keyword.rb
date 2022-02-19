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

  scope :deathrattle, -> { find_by(type: 'Deathrattle') }
  scope :battlecry, -> { find_by(type: 'Battlecry') }

  def trigger(invoking_card, target = '')
    final_target = (target.empty? ? evaluate_target_chain(invoking_card) : target)
    final_target.send(action, modifier)
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
end
