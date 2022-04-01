require 'rails_helper'
require_relative 'game_scenario'

RSpec.describe Player, type: :model do
  describe 'Associations' do
    it { should belong_to(:race) }
    it { should belong_to(:archetype) }
    it { should belong_to(:game) }
    it { should belong_to(:user) }
    it { should have_one(:gamestate_deck) }
  end
  describe 'Validation Presence' do
    it { should validate_presence_of(:health_cap) }
    it { should validate_presence_of(:health_current) }
    it { should validate_presence_of(:cost_cap) }
    it { should validate_presence_of(:cost_current) }
    it { should validate_presence_of(:resource_cap) }
    it { should validate_presence_of(:resource_current) }
  end
  describe 'Validation Numericality' do
    it { should validate_numericality_of(:health_cap) }
    it { should validate_numericality_of(:health_current) }
    it { should validate_numericality_of(:cost_cap) }
    it { should validate_numericality_of(:cost_current) }
    it { should validate_numericality_of(:resource_cap) }
    it { should validate_numericality_of(:resource_current) }
  end

  describe 'Value Cap Numericality' do
    it {
      subject.health_cap = 25
      should validate_numericality_of(:health_current).is_less_than_or_equal_to(subject.health_cap)
    }
    it {
      subject.cost_cap = 25
      should validate_numericality_of(:cost_current).is_less_than_or_equal_to(subject.cost_cap)
    }
    it {
      subject.resource_cap = 25
      should validate_numericality_of(:resource_current).is_less_than_or_equal_to(subject.resource_cap)
    }
  end

  describe 'Player creation from deck' do
    include_context 'Shared Game Scenario'

    it 'Creates valid Game Player from AccountDeck input' do
      game.player_one.prepare_player(queued_deck_user_one)
      expect(game.player_one).to be_valid
    end
  end

  describe 'Mulligan Phase' do
    include_context 'Shared Game Scenario'

    subject do
      game.player_one
    end
    it 'Moves 3 cards from deck to mulligan stage for player_one' do
      subject.draw_mulligan_cards
      expect(subject.cards.in_mulligan.size).to eql(3)
      expect(subject.cards.in_deck.size).to eql(27)
    end
    it 'Moves 4 cards from deck to mulligan stage for player_two' do
      subject.turn_order = false
      subject.draw_mulligan_cards
      expect(subject.cards.in_mulligan.size).to eql(4)
      expect(subject.cards.in_deck.size).to eql(26)
    end
    it 'Sets starting hand to mulligan cards' do
      subject.draw_mulligan_cards
      subject.set_starting_hand
      expect(subject.cards.in_hand.size).to eql(subject.turn_order ? 3 : 4)
      expect(subject.cards.in_mulligan.size).to eql(0)
      expect(subject.cards.in_deck.size).to eql(subject.turn_order ? 27 : 26)
    end
    it 'Ends Mulligan Phase after player_two mulligan' do
      expect(game.status).to eql('mulligan')
      game.begin_first_turn
      expect(game.status).to eql('ongoing')
    end
  end

  describe 'Prepare new turn' do
    include_context 'Shared Game Scenario'

    subject do
      game.player_one
    end
    it 'Increments player cost and resource' do
      expect { subject.prepare_new_turn }.to change { subject.cost_cap }.by(1)
      expect { subject.prepare_new_turn }.to change { subject.resource_cap }.by(1)
    end
    it 'Sets player cost and resource to their cap' do
      expect { subject.prepare_new_turn }.to change { subject.cost_current }.to eql(subject.cost_cap + 1)
      expect { subject.prepare_new_turn }.to change { subject.resource_current }.to eql(subject.resource_cap + 1)
    end
    it 'Cannot increment player cost past 10' do
      subject.cost_cap = 10
      expect { subject.prepare_new_turn }.to_not change { subject.cost_cap }
    end
    it 'Cannot increment player resource past 20' do
      subject.resource_cap = 20
      expect { subject.prepare_new_turn }.to_not change { subject.resource_cap }
    end
    it 'Draws 1 card from deck into hand' do
      expect { subject.prepare_new_turn }.to change { subject.gamestate_deck.card_count }.by(-1)
      expect { subject.prepare_new_turn }.to change { subject.cards.in_hand.count }.by(1)
    end
    it 'Wakes attack cards' do
      subject.prepare_new_turn
      expect(subject.cards.in_battle.count).to eql(subject.party_cards.in_battle.is_attacking.count)
    end
  end
end
