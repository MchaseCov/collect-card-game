require 'rails_helper'

RSpec.describe Player, type: :model do
  subject { FactoryBot.create(:player) }

  context 'Creation' do
    it { is_expected.to be_valid }
  end

  describe 'Associations' do
    it { should belong_to(:race) }
    it { should belong_to(:archetype) }
    it { should belong_to(:game) }
    it { should belong_to(:user) }
    it { should have_one(:gamestate_deck) }
  end

  describe 'Validation Numericality' do
    it { should validate_numericality_of(:health_cap) }
    it { should validate_numericality_of(:resource_cap) }
    it { should validate_numericality_of(:cost_cap) }
    it { should validate_numericality_of(:cost_current) }
    it { should validate_numericality_of(:resource_current) }
    it { should validate_numericality_of(:health_current).is_less_than_or_equal_to(subject.health_cap) }
    it { should validate_numericality_of(:attack).is_greater_than_or_equal_to(0) }
  end
end
