require 'rails_helper'

RSpec.describe CardReference, type: :model do
  subject { FactoryBot.create :card_reference }

  context 'Card Reference creation' do
    it { is_expected.to be_valid }
  end

  context 'validations' do
    context 'presence' do
      %i[cost card_type card_constant_id].each do |att|
        it { should validate_presence_of(att) }
      end
    end
    context 'inclusion' do
      it { should validate_inclusion_of(:card_type).in_array(%w[PartyCard SpellCard]) }
    end
  end

  describe 'Associations' do
    it { should belong_to(:card_constant) }
    it { should have_many(:account_deck_card_references) }
    it { should have_many(:account_decks).through(:account_deck_card_references) }
  end
end
