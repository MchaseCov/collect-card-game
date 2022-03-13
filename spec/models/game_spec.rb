require 'rails_helper'
require_relative 'game_scenario'

RSpec.describe Game, type: :model do
  describe 'Associations' do
    it { should have_many(:players) }
  end

  describe 'Game Creation' do
    include_context 'Shared Game Scenario'

    subject { game }
    it 'Creates player one' do
      expect(subject.player_one).to be_present
    end
    it 'Creates player two' do
      expect(subject.player_two).to be_present
    end
    it 'Prepares players to be valid' do
      expect(subject.player_one).to be_valid
      expect(subject.player_two).to be_valid
    end
    it 'Creates a duplicate gamestate deck for both players' do
      expect(subject.player_one.gamestate_deck).to be_present
      expect(subject.player_two.gamestate_deck).to be_present
    end
  end

  describe 'Card Attacking' do
    include_context 'Shared Game Scenario'

    subject { game }
    let(:attacking_card) { subject.player_one.party_cards.first }
    let(:defending_card) { subject.player_two.party_cards.first }

    it 'Damages Both Cards' do
      attacking_card.update(location: 'battle', status: 'attacking')
      expect do
        subject.conduct_attack(attacking_card, defending_card)
      end.to change { defending_card.health }
        .by(-attacking_card.attack)
        .and change { attacking_card.health }
        .by(-defending_card.attack)
    end

    it 'It Kills A Card With 0 Or Less Health' do
      # Defending card has 4 health, Attacking Card has 5 attack.
      attacking_card.update(location: 'battle', status: 'attacking')
      subject.conduct_attack(attacking_card, defending_card)
      expect(defending_card.location).to eql('graveyard')
      expect(defending_card.status).to eql('dead')
    end

    it 'Returns if Attacking Card is not Attacking Status' do
      expect(subject.conduct_attack(attacking_card, defending_card)).to eq(nil)
      expect { subject.conduct_attack(attacking_card, defending_card) }.not_to change { defending_card }
    end
  end

  describe 'Playing Party Card From Hand To Board' do
    include_context 'Shared Game Scenario'

    subject { game }
    let(:played_card) { subject.player_one.party_cards.first }
    it 'Puts chosen card into battle' do
      subject.put_card_in_play(played_card, 1, false)
      expect(played_card.location).to eql('battle')
    end
    it 'Moves cards to right when desired position is already taken' do
      subject.player_one.update(cost_cap: 20, cost_current: 20)
      already_in_play = subject.player_one.party_cards.second
      subject.put_card_in_play(already_in_play, 1, false)
      expect do
        subject.put_card_in_play(played_card, 1, false)
      end.to change { already_in_play.reload.position }.by(1)
    end
    it 'Cannot play a card that costs more than user gold' do
      subject.player_one.update(cost_cap: 0, cost_current: 0)
      subject.put_card_in_play(played_card, 1, false)
      expect { subject.put_card_in_play(played_card, 1, false) }.to_not change { played_card.location }
    end
  end
end
