require 'rails_helper'

RSpec.describe Card, type: :model do
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

  describe 'Value Cap Numericality' do
    it 'Cannot have health higher than the cap' do
      subject.health_cap = 25
      should validate_numericality_of(:health).is_less_than_or_equal_to(subject.health_cap)
    end
  end
end
