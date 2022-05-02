require 'rails_helper'

RSpec.describe Card, type: :model do
  subject { FactoryBot.create(:card, type: 'PartyCard') } # Type is arbitrary for these tests

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
  describe 'Validation Presence' do
    it { should validate_presence_of(:location) }
  end
  describe 'Validation Numericality' do
    it { should validate_numericality_of(:cost) }
  end
end
