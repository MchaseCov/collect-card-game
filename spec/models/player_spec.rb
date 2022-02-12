require 'rails_helper'

RSpec.describe Player, type: :model do
  let(:user) { User.create!(email: 'foo@bar.com', password: '123123123') }
  let(:archetype) { Archetype.create!(name: 'Ranger', description: 'RangerDesc', resource_type: 'hybrid') }
  let(:race) do
    Race.create!(name: 'Human', description: 'Humandesc', health_modifier: 0, cost_modifier: 0, resource_modifier: 0)
  end
  let(:party_card_parent) do
    PartyCardParent.create!(name: 'TestCard', cost_default: 1, attack_default: 1, health_default: 1,
                            archetype_id: archetype.id)
  end

  let(:queued_deck) do
    AccountDeck.create!(name: 'rspec deck',
                        user_id: user.id,
                        card_count: 30,
                        archetype_id: archetype.id,
                        race_id: race.id)
  end

  let(:game) { Game.create! }

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

  describe 'Player creation from deck' do
    it 'Creates valid Game Player from AccountDeck input' do
      game.player_one.prepare_player(queued_deck)
      expect(game.player_one).to be_valid
    end
  end
end
