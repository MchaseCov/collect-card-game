require 'rails_helper'

RSpec.describe PartyCardParent, type: :model do
  describe 'Associations' do
    it { should belong_to(:archetype) }
    it { should have_many(:account_deck_party_card_parents) }
    it { should have_many(:account_decks).through(:account_deck_party_card_parents) }
    it { should have_many(:keywords) }
  end
  describe 'Validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:cost_default) }
    it { should validate_presence_of(:attack_default) }
    it { should validate_presence_of(:health_default) }
  end
end
