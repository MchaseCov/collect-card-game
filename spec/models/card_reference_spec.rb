require 'rails_helper'

RSpec.describe CardReference, type: :model do
  describe 'Associations' do
    it { should belong_to(:card_constant) }
    it { should have_many(:account_deck_card_references) }
    it { should have_many(:account_decks).through(:account_deck_card_references) }
  end
  describe 'Validations' do
    let(:archetype) { Archetype.create!(name: 'Ranger', description: 'RangerDesc', resource_type: 'hybrid') }

    let(:card_constant) { CardConstant.create!(name: 'TestCard', tribe: 'Beast', archetype_id: archetype.id) }
    subject do
      CardReference.create!(cost: 1, attack: 5, health: 10, card_type: 'PartyCard', card_constant_id: card_constant.id)
    end

    %i[cost card_type card_constant_id].each { |att| it { is_expected.to validate_presence_of(att) } }
    %i[health attack].each { |att| it { is_expected.to  validate_numericality_of(att) } }
    it { is_expected.to validate_uniqueness_of(:card_constant_id) }
    it { is_expected.to validate_inclusion_of(:card_type).in_array(%w[PartyCard SpellCard]) }
  end
end
