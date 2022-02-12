require 'rails_helper'

RSpec.describe GamestateDeck, type: :model do
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
  let(:game) { Game.create! }
  let(:p1) do
    Player.create!(health_cap: 30,
                   health_current: 30,
                   cost_cap: 1,
                   cost_current: 1,
                   resource_cap: 1,
                   resource_current: 1,
                   race: race,
                   archetype: archetype,
                   user: user,
                   game: game,
                   turn_order: true)
  end

  subject do
    described_class.create!(card_count: 30, player: p1, game: game)
  end

  describe 'Associations' do
    it { should belong_to(:player) }
    it { should belong_to(:game) }
  end
  describe 'Validations' do
    it { should validate_presence_of(:card_count) }
    it { should validate_numericality_of(:card_count) }
  end

  describe 'Prepare deck for game' do
    it 'Creates cards' do
      queued_deck.party_card_parents << party_card_parent
      queued_deck.reload
      subject.prepare_deck(queued_deck)
      expect(subject.party_card_gamestates.count).to eq(queued_deck.party_card_parents.count)
      expect(subject.party_card_gamestates.count).to_not eq(0)
    end
    it 'Creates cards that reference the same parent as the account deck' do
      queued_deck.party_card_parents << party_card_parent
      queued_deck.reload
      subject.prepare_deck(queued_deck)
      expect(subject.party_card_gamestates.first.party_card_parent).to eq(queued_deck.party_card_parents.first)
    end
  end
end
