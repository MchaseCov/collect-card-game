require 'rails_helper'
require_relative 'game_scenario'

RSpec.describe ActiveBuff, type: :model do
  describe 'Associations' do
    it { should belong_to(:buff) }
    it { should belong_to(:buffable) }
  end
  describe 'It has a gamestate card and buff' do
    include_context 'Shared Game Scenario'
    let(:buffed_card) { game.player_one.party_card_gamestates.first }
    it 'Adds buffs to cards' do
      expect { buffed_card.buffs << buff }.to change { ActiveBuff.count }.by(1)
    end
  end

  describe 'Runs buff callbacks' do
    describe 'It has a gamestate card and buff' do
      include_context 'Shared Game Scenario'
      let(:buffed_card) { game.player_one.party_card_gamestates.first }
      it 'Buffs card when added' do
        expect { buffed_card.buffs << buff }.to change { buffed_card.health_cap }.by(2)
      end
      it 'Unbuffs Card when removed' do
        expect do
          buffed_card.buffs << buff
          buffed_card.buffs.destroy(buff)
        end.to change { buffed_card.health_cap }.by(0)
      end
    end
  end
end
