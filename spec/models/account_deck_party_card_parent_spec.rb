require 'rails_helper'

RSpec.describe AccountDeckPartyCardParent, type: :model do
  describe 'Associations' do
    it { should belong_to(:account_deck) }
    it { should belong_to(:party_card_parent) }
  end
end
