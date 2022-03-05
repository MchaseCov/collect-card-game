require 'rails_helper'
require_relative 'game_scenario'

RSpec.describe Keyword, type: :model do
  include_context 'Shared Game Scenario'

  describe 'Associations' do
    it { should belong_to(:party_card_parent) }
  end
  subject do
    Keyword.create!(type: 'Battlecry',
                    player_choice: true,
                    target: %w[player_of_card cards in_battle beast_tribe],
                    action: 'increase_health_cap',
                    modifier: 2,
                    party_card_parent_id: party_card_parent.id,
                    body_text: 'Give +2 health to a friendly Beast in battle.')
  end

  describe 'Validations' do
    it 'Validates presence of attributes' do
      should validate_presence_of(:type)
      should validate_presence_of(:party_card_parent_id)

      should validate_presence_of(:target)
    end
    it 'Cannot assign two of the same type to the same card' do
      should validate_uniqueness_of(:type).scoped_to(:party_card_parent_id)
    end
    it { should validate_inclusion_of(:type).in_array(%w[Deathrattle Battlecry]) }
  end

  describe 'Keywords that send a buff' do
    let(:buffed_card) { game.player_one.party_card_gamestates.first }

    it 'Can have a buff' do
      subject.buff = buff
      expect(subject.buff).to eql(buff)
    end

    it 'Adds Buffs To Cards When Triggered' do
      subject.buff = buff
      buffed_card.update(location: 'battle')
      current_health = buffed_card.health_cap
      subject.trigger(buffed_card, buffed_card.id)
      expect(buffed_card.buffs.first).to eq(buff)
      expect(buffed_card.reload.health_cap).to eq(current_health + 2)
    end
  end
end
