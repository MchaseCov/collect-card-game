require 'rails_helper'
RSpec.describe SpellCard, type: :model do
  subject { FactoryBot.create(:spell_card) }

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
end
