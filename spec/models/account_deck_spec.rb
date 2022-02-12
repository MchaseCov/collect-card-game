require 'rails_helper'

RSpec.describe AccountDeck, type: :model do
  describe 'Associations' do
    it { should belong_to(:user) }
    it { should belong_to(:race) }
    it { should belong_to(:archetype) }
    it { should have_many(:account_deck_party_card_parents) }
    it { should have_many(:party_card_parents).through(:account_deck_party_card_parents) }
  end
  describe 'Validations' do
    it { should validate_presence_of(:name) }
  end
end
