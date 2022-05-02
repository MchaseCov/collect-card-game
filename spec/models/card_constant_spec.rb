require 'rails_helper'

RSpec.describe CardConstant, type: :model do
  subject { FactoryBot.create :card_constant }

  context 'Card Constant creation' do
    it { is_expected.to be_valid }
  end

  context 'validations' do
    context 'presence' do
      it { should validate_presence_of(:name) }
    end

    context 'uniqueness' do
      it { should validate_uniqueness_of(:name) }
    end
  end

  context 'Associations' do
    context 'belongs_to' do
      it { should belong_to(:archetype) }
      it { should belong_to(:summoner).optional }
    end
    context 'has_many' do
      it { should have_many(:keywords) }
      it { should have_many(:cards) }
    end
    context 'has_one' do
      it { should have_one(:card_reference) }
      it { should have_one(:token) }
      it { should have_one(:battlecry) }
      it { should have_one(:taunt) }
      it { should have_one(:deathrattle) }
      it { should have_one(:aura) }
      it { should have_one(:listener) }
    end
  end

  context 'when Card Constant is a token' do
    let(:token_archetype) { FactoryBot.create :token_archetype }

    context 'when summoner id is blank' do
      let(:token_constant) { FactoryBot.build(:card_constant, archetype: token_archetype) }
      it 'is not valid' do
        expect(token_constant).to_not be_valid
      end
      it 'does not save' do
        expect(token_constant.save).to be false
      end
    end

    context 'when summoner id is present' do
      let(:token_constant) { FactoryBot.build(:card_constant, archetype: token_archetype, summoner: subject) }
      it 'is valid' do
        expect(token_constant).to be_valid
      end
      it 'saves' do
        expect(token_constant.save).to be true
      end
    end
  end
end
