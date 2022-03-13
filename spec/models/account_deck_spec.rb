require 'rails_helper'
require_relative 'game_scenario'

RSpec.describe AccountDeck, type: :model do
  let(:user) { User.create!(email: 'foo@bar.com', password: '123123123') }
  let(:archetype) { Archetype.create!(name: 'Ranger', description: 'RangerDesc', resource_type: 'hybrid') }
  let(:race) do
    Race.create!(name: 'Human', description: 'H', health_modifier: 0, cost_modifier: 0, resource_modifier: 0)
  end
  subject do
    AccountDeck.create!(name: 'rspec deck',
                        user_id: user.id,
                        card_count: 0,
                        archetype_id: archetype.id,
                        race_id: race.id)
  end
  describe 'Subject is valid' do
    it { expect(subject).to be_valid }
  end
  describe 'Associations' do
    it { should belong_to(:user) }
    it { should belong_to(:race) }
    it { should belong_to(:archetype) }
    it { should have_many(:account_deck_card_references) }
    it { should have_many(:card_references).through(:account_deck_card_references) }
  end
  describe 'Validations' do
    it { should validate_presence_of(:name) }
  end

  let(:card_constant) { CardConstant.create!(name: 'TestCard', tribe: 'Beast', archetype_id: archetype.id) }
  let(:card_reference) do
    CardReference.create!(cost: 1, attack: 5, health: 10, card_type: 'party_card', card_constant_id: card_constant.id)
  end

  describe '#add_card' do
    it 'should create new entry in account_deck_card_references' do
      expect do
        subject.add_card(card_reference)
      end.to change { subject.reload.account_deck_card_references.count }.by(1)
    end
    it 'should increment total card count' do
      expect do
        subject.add_card(card_reference)
      end.to change { subject.reload.card_count }.by(1)
    end
    it 'should allow neutral archetype cards' do
      expect do
        card_reference.card_constant.archetype.name = 'Neutral' # This does not actually change the subject's shared archetype name
        subject.add_card(card_reference)
      end.to change { subject.reload.account_deck_card_references.count }.by(1)
    end
    it 'should not add a card to a deck of 30 cards' do
      expect do
        subject.card_count = 30
        subject.add_card(card_reference)
      end.to_not(change { subject.reload.card_count })
    end
    it 'should not allow a card from a different archetype' do
      expect do
        card_reference.card_constant.archetype.name = 'Mage' # This does not actually change the subject's shared archetype name
        subject.add_card(card_reference)
      end.to_not(change { subject.reload.card_count })
    end
  end

  describe '#destroy_card' do
    before(:each) do
      subject.add_card(card_reference)
      subject.reload
    end
    it 'should remove entry in account_deck_card_references' do
      expect do
        subject.destroy_card(card_reference)
      end.to change { subject.reload.account_deck_card_references.count }.by(-1)
    end
    it 'should decrement total card count' do
      expect do
        subject.destroy_card(card_reference)
      end.to change { subject.reload.card_count }.by(-1)
    end
    it 'should not remove duplicate cards' do
      expect do
        subject.add_card(card_reference) # Adding a second card, the first is in before(:each)
        subject.destroy_card(card_reference)
      end.to_not(change { subject.reload.account_deck_card_references.count })
    end
  end
end
