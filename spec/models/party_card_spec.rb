require 'rails_helper'
require_relative 'game_scenario'
RSpec.describe PartyCard, type: :model do
  describe 'Associations' do
    it { should belong_to(:card_constant) }
    it { should belong_to(:gamestate_deck) }
    it { should have_one(:player) }
    it { should have_one(:game) }
    it { should have_many(:active_buffs) }
    it { should have_many(:buffs) }
  end
  describe 'Validation Presence' do
    %i[health_cap health attack status cost location].each do |att|
      it { should validate_presence_of(att) }
    end
  end
  describe 'Validation Numericality' do
    it { should validate_numericality_of(:health_cap) }
    it { should validate_numericality_of(:attack) }
    it { should validate_numericality_of(:cost) }
  end

  describe 'Value Cap Numericality' do
    it 'Cannot have health higher than the cap' do
      subject.health_cap = 25
      should validate_numericality_of(:health).is_less_than_or_equal_to(subject.health_cap)
    end
  end

  describe 'integer methods' do
    include_context 'Shared Game Scenario'

    subject { game.player_one.party_cards.first }
    it 'increments' do
      subject.position = 1
      %i[position health_cap health].each do |attribute|
        expect { subject.send("increment_#{attribute}") }.to change { subject.send(attribute) }.by(1)
      end
    end
    it 'decrements' do
      subject.position = 2
      %i[position health_cap health].each do |attribute|
        expect { subject.send("decrement_#{attribute}") }.to change { subject.send(attribute) }.by(-1)
      end
    end
  end
end
