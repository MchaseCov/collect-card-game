require 'rails_helper'
RSpec.describe PartyCard, type: :model do
  subject { FactoryBot.create(:party_card) }

  context 'Card creation' do
    it { is_expected.to be_valid }
  end

  describe 'Associations' do
    it { should belong_to(:card_constant) }
    it { should belong_to(:gamestate_deck) }
    it { should have_one(:player) }
    it { should have_one(:game) }
    it { should have_many(:active_buffs) }
    it { should have_many(:buffs) }
  end

  describe 'Validation Numericality' do
    it { should validate_numericality_of(:health_cap).is_greater_than_or_equal_to(0) }
    it { should validate_numericality_of(:attack).is_greater_than_or_equal_to(0) }
    it { should validate_numericality_of(:health).is_less_than_or_equal_to(subject.health_cap) }
  end

  describe '#increment_position' do
    before { subject.position = 5 }
    it 'increments by 1 with no argument' do
      expect { subject.increment_position }.to change { subject.position }.by(1)
    end
    it 'increments by an argument' do
      expect { subject.increment_position(2) }.to change { subject.position }.by(2)
    end
  end

  describe '#decrement_position' do
    before { subject.position = 5 }
    it 'decrements by 1 with no argument' do
      expect { subject.decrement_position }.to change { subject.position }.by(-1)
    end
    it 'decrements by an argument' do
      expect { subject.decrement_position(2) }.to change { subject.position }.by(-2)
    end
  end

  describe '#put_card_in_battle(position)' do
    before { subject.put_card_in_battle(3) }
    it 'updates attributes' do
      expect(subject.status).to eq('sleeping')
      expect(subject.location).to eq('battlefield')
      expect(subject.position).to eq(3)
    end
  end

  describe '#return_to_hand' do
    before { subject.return_to_hand }
    it 'updates attributes' do
      expect(subject.status).to eq('unplayed')
      expect(subject.location).to eq('hand')
    end
  end

  describe '#silence' do
  end

  describe '#increase_stats' do
    it 'increments by 1 with no argument' do
      expect { subject.increase_stats }.to(change { subject.health_cap }.by(1)
                                       .and(change { subject.attack }.by(1)
                                       .and(change { subject.health }.by(1))))
    end
    it 'increments with an argument' do
      expect { subject.increase_stats(3) }.to(change { subject.health_cap }.by(3)
                                       .and(change { subject.attack }.by(3)
                                       .and(change { subject.health }.by(3))))
    end
  end

  describe '#decrease_stats' do
    before { subject.increase_stats(5) }

    it 'decrements by 1 with no argument' do
      expect { subject.decrease_stats }.to(change { subject.health_cap }.by(-1)
                                       .and(change { subject.attack }.by(-1)
                                       .and(change { subject.health }.by(-1))))
    end
    it 'decrements with an argument' do
      expect { subject.decrease_stats(3) }.to(change { subject.health_cap }.by(-3)
                                       .and(change { subject.attack }.by(-3)
                                       .and(change { subject.health }.by(-3))))
    end
  end

  describe '#put_card_in_graveyard' do
    before { subject.put_card_in_graveyard }
    it 'updates attributes' do
      expect(subject.status).to eq('dead')
      expect(subject.location).to eq('graveyard')
    end
  end
end
