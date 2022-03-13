require 'rails_helper'

RSpec.describe AccountDeckCardReference, type: :model do
  describe 'Associations' do
    it { should belong_to(:account_deck) }
    it { should belong_to(:card_reference) }
  end
end
