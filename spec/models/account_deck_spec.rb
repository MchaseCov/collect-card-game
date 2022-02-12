require 'rails_helper'

RSpec.describe AccountDeck, type: :model do
  let(:user) { User.create!(email: 'foo@bar.com', password: '123123123') }
  let(:archetype) { Archetype.create!(name: 'Ranger', description: 'RangerDesc', resource_type: 'hybrid') }
  let(:race) do
    Race.create!(name: 'Human', description: 'Humandesc', health_modifier: 0, cost_modifier: 0, resource_modifier: 0)
  end
  let(:party_card_parent) do
    PartyCardParent.create!(name: 'TestCard', cost_default: 1, attack_default: 1, health_default: 1,
                            archetype_id: archetype.id)
  end

  subject do
    described_class.create!(name: 'rspec deck',
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
    it { should have_many(:account_deck_party_card_parents) }
    it { should have_many(:party_card_parents).through(:account_deck_party_card_parents) }
  end
  describe 'Validations' do
    it { should validate_presence_of(:name) }
  end

  describe '#add_party_card' do
    it 'should create new entry in account_deck_party_card_parents' do
      expect do
        subject.add_party_card(party_card_parent)
      end.to change { subject.reload.account_deck_party_card_parents.count }.by(1)
    end
    it 'should increment total card count' do
      expect do
        subject.add_party_card(party_card_parent)
      end.to change { subject.reload.card_count }.by(1)
    end
    it 'should allow neutral archetype cards' do
      expect do
        party_card_parent.archetype.name = 'Neutral' # This does not actually change the subject's shared archetype name
        subject.add_party_card(party_card_parent)
      end.to change { subject.reload.account_deck_party_card_parents.count }.by(1)
    end
    it 'should not add a card to a deck of 30 cards' do
      expect do
        subject.card_count = 30
        subject.add_party_card(party_card_parent)
      end.to_not(change { subject.reload.card_count })
    end
    it 'should not allow a card from a different archetype' do
      expect do
        party_card_parent.archetype.name = 'Mage' # This does not actually change the subject's shared archetype name
        subject.add_party_card(party_card_parent)
      end.to_not(change { subject.reload.card_count })
    end
  end

  describe '#destroy_party_card' do
    before(:each) do
      subject.add_party_card(party_card_parent)
      subject.reload
    end
    it 'should remove entry in account_deck_party_card_parents' do
      expect do
        subject.destroy_party_card(party_card_parent)
      end.to change { subject.reload.account_deck_party_card_parents.count }.by(-1)
    end
    it 'should decrement total card count' do
      expect do
        subject.destroy_party_card(party_card_parent)
      end.to change { subject.reload.card_count }.by(-1)
    end
    it 'should not remove duplicate cards' do
      expect do
        subject.add_party_card(party_card_parent) # Adding a second card, the first is in before(:each)
        subject.destroy_party_card(party_card_parent)
      end.to_not(change { subject.reload.account_deck_party_card_parents.count })
    end
  end
end
