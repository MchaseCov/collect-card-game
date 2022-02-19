require 'rails_helper'
require_relative 'game_scenario'

RSpec.describe Keyword, type: :model do
  describe 'Associations' do
    it { should belong_to(:party_card_parent) }
  end
  describe 'Validations' do
    include_context 'Shared Game Scenario'
    subject do
      Keyword.new(type: 'Deathrattle', player_choice: false, target: ['game', 'opposing player of, invoking_card.player'],
                  modifier: 1, party_card_parent_id: party_card_parent.id)
    end

    it 'Validates presence of attributes' do
      should validate_presence_of(:type)
      should validate_presence_of(:party_card_parent_id)
      should validate_presence_of(:player_choice)
      should validate_presence_of(:target)
      should validate_presence_of(:modifier)
    end
    it 'Cannot assign two of the same type to the same card' do
      should validate_uniqueness_of(:type).scoped_to(:party_card_parent_id)
    end
    it { should validate_inclusion_of(:type).in_array(%w[Deathrattle Battlecry]) }
    it { should validate_numericality_of(:modifier) }
  end
end
