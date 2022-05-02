require 'rails_helper'
require_relative 'game_scenario'

RSpec.describe AccountDeck, type: :model do
  subject { FactoryBot.create(:account_deck) }

  context 'Account deck creation' do
    it { is_expected.to be_valid }
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

  describe '#add_card' do
    let(:wizard_archetype) { FactoryBot.create :wizard_archetype }
    let(:neutral_archetype) { FactoryBot.create :neutral_archetype }
    let(:ranger_archetype) { FactoryBot.create :ranger_archetype }
    let(:card_to_add_constant) { FactoryBot.create(:card_constant, archetype: wizard_archetype) }
    let(:card_to_add) { FactoryBot.create(:card_reference, card_constant: card_to_add_constant) }

    context 'When deck is not full' do
      it 'Adds a card of the same archetype' do
        expect do
          subject.archetype = wizard_archetype
          subject.add_card(card_to_add)
        end.to change { subject.card_count }.by(1)
      end

      it 'Adds a card of the neutral archetype' do
        card_to_add_constant.archetype = neutral_archetype
        expect do
          subject.add_card(card_to_add)
        end.to change { subject.card_count }.by(1)
      end

      it 'Does not add a card of a foreign archetype' do
        card_to_add_constant.archetype = ranger_archetype
        expect do
          subject.add_card(card_to_add)
        end.to_not(change { subject.card_count })
      end
    end

    context 'When deck is full' do
      before { subject.card_count = 30 }
      it 'Does not add a card of the same archetype' do
        expect do
          subject.archetype = wizard_archetype
          subject.add_card(card_to_add)
        end.to_not(change { subject.card_count })
      end

      it 'Does not add a card of the neutral archetype' do
        card_to_add_constant.archetype = neutral_archetype
        expect do
          subject.add_card(card_to_add)
        end.to_not(change { subject.card_count })
      end

      it 'Does not add a card of a foreign archetype' do
        card_to_add_constant.archetype = ranger_archetype
        expect do
          subject.add_card(card_to_add)
        end.to_not(change { subject.card_count })
      end
    end
  end

  describe '#destroy_card' do
    let(:neutral_archetype) { FactoryBot.create :neutral_archetype }
    let(:card_existing_in_deck_constant) { FactoryBot.create(:card_constant, archetype: neutral_archetype) }
    let(:card_existing_in_deck) { FactoryBot.create(:card_reference, card_constant: card_existing_in_deck_constant) }

    before(:each) do
      subject.add_card(card_existing_in_deck)
      subject.reload
    end
    it 'removes entry in account_deck_card_references' do
      expect do
        subject.destroy_card(card_existing_in_deck)
      end.to change { subject.reload.account_deck_card_references.count }.by(-1)
    end
    it 'decrements card count' do
      expect do
        subject.destroy_card(card_existing_in_deck)
      end.to change { subject.card_count }.by(-1)
    end
    it 'does not remove duplicate cards' do
      expect do
        subject.add_card(card_existing_in_deck)
        subject.destroy_card(card_existing_in_deck)
      end.to_not(change { subject.reload.account_deck_card_references.count })
    end
  end
end
