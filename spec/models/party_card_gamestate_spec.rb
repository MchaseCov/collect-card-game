require 'rails_helper'

RSpec.describe PartyCardGamestate, type: :model do
  describe 'Associations' do
    it { should belong_to(:archetype) }
    it { should belong_to(:party_card_parent) }
    it { should belong_to(:gamestate_deck) }
    it { should have_one(:player) }
    it { should have_one(:game) }
  end
  describe 'Validation Presence' do
    it { should validate_presence_of(:health_cap) }
    it { should validate_presence_of(:health_current) }
    it { should validate_presence_of(:cost_current) }
    it { should validate_presence_of(:attack_cap) }
    it { should validate_presence_of(:attack_current) }
    it { should validate_presence_of(:location) }
    it { should validate_presence_of(:status) }
  end
  describe 'Validation Numericality' do
    it { should validate_numericality_of(:health_cap) }
    it { should validate_numericality_of(:attack_cap) }
  end

  describe 'Value Cap Numericality' do
    it 'Cannot have health higher than the cap' do
      subject.health_cap = 25
      should validate_numericality_of(:health_current).is_less_than_or_equal_to(subject.health_cap)
    end
    it 'Cannot have attack higher than the cap' do
      subject.attack_cap = 25
      should validate_numericality_of(:attack_current).is_less_than_or_equal_to(subject.attack_cap)
    end
    it 'is skipped', skip: 'Shoulda does not seem to support in(x..y)' do
      should validate_numericality_of(:cost_current).is_greater_than(-1).is_less_than(11)
    end
  end
end
