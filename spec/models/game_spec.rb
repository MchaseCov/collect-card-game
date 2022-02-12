require 'rails_helper'

RSpec.describe Game, type: :model do
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
    AccountDeck.create!(name: 'rspec deck',
                        user_id: user.id,
                        card_count: 30,
                        archetype_id: archetype.id,
                        race_id: race.id)
  end

  describe 'Associations' do
    it { should belong_to(:winner).without_validating_presence }
    it { should have_one(:player_one) }
    it { should have_one(:player_two) }
  end

  subject { described_class.create! }

  describe 'Game Creation' do
    it 'Creates player one' do
      expect(subject.player_one).to be_present
    end
    it 'Creates player two' do
      expect(subject.player_two).to be_present
    end
    it 'Prepares players to be valid' do
      subject.populate_players(queued_deck, queued_deck)
      expect(subject.player_one).to be_valid
    end
    it 'Creates a duplicate gamestate deck of player one' do
      subject.populate_players(queued_deck, queued_deck)
      subject.populate_decks(queued_deck, queued_deck)
      expect(subject.player_one.gamestate_deck).to be_present
    end
    it 'Creates a duplicate gamestate deck of player two' do
      subject.populate_players(queued_deck, queued_deck)
      subject.populate_decks(queued_deck, queued_deck)
      expect(subject.player_two.gamestate_deck).to be_present
    end
  end
end
