require 'rails_helper'

RSpec.describe Player, type: :model do
  describe 'Associations' do
    it { should belong_to(:race) }
    it { should belong_to(:archetype) }
    it { should belong_to(:game) }
    it { should belong_to(:user) }
    it { should have_one(:gamestate_deck) }
  end
  describe 'Validation Presence' do
    it { should validate_presence_of(:health_cap) }
    it { should validate_presence_of(:health_current) }
    it { should validate_presence_of(:cost_cap) }
    it { should validate_presence_of(:cost_current) }
    it { should validate_presence_of(:resource_cap) }
    it { should validate_presence_of(:resource_current) }
    it { should validate_presence_of(:turn_order) }
  end
  describe 'Validation Numericality' do
    it { should validate_numericality_of(:health_cap) }
    it { should validate_numericality_of(:health_current) }
    it { should validate_numericality_of(:cost_cap) }
    it { should validate_numericality_of(:cost_current) }
    it { should validate_numericality_of(:resource_cap) }
    it { should validate_numericality_of(:resource_current) }
  end

  describe 'Value Cap Numericality' do
    it {
      subject.health_cap = 25
      should validate_numericality_of(:health_current).is_less_than_or_equal_to(subject.health_cap)
    }
    it {
      subject.cost_cap = 25
      should validate_numericality_of(:cost_current).is_less_than_or_equal_to(subject.cost_cap)
    }
    it {
      subject.resource_cap = 25
      should validate_numericality_of(:resource_current).is_less_than_or_equal_to(subject.resource_cap)
    }
  end
end
