require 'rails_helper'

RSpec.describe Player, type: :model do
  let(:user) { User.create!(email: 'foo@bar.com', password: '123123123') }
  let(:archetype) { Archetype.create!(name: 'Ranger', description: 'RangerDesc', resource_type: 'hybrid') }
  let(:race) do
    Race.create!(name: 'Human', description: 'Humandesc', health_modifier: 0, cost_modifier: 0, resource_modifier: 0)
  end
  let(:party_card_parent) do
    PartyCardParent.create!(name: 'TestCard', cost_default: 1, attack_default: 1, health_default: 1,
                            archetype_id: archetype.id)
  end

  let(:queued_deck) do
    deck = AccountDeck.create!(name: 'rspec deck',
                               user_id: user.id,
                               card_count: 30,
                               archetype_id: archetype.id,
                               race_id: race.id)
    30.times { deck.party_card_parents << party_card_parent }
    deck
  end

  let(:game) { Game.create! }

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
    it 'Creates valid Game Player from AccountDeck input' do
      game.player_one.prepare_player(queued_deck)
      expect(game.player_one).to be_valid
    end
  end

  describe 'Mulligan Phase' do
    subject do
      game.player_one.prepare_player(queued_deck)
      game.player_one.gamestate_deck.prepare_deck(queued_deck)
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
      subject.set_starting_hand
      expect(game.status).to eql('mulligan')
      game.turn = false
      subject.set_starting_hand
      expect(game.status).to eql('ongoing')
    end
  end

  describe 'Prepare new turn' do
    subject do
      game.player_one.prepare_player(queued_deck)
      game.player_one.gamestate_deck.prepare_deck(queued_deck)
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
  end
end
