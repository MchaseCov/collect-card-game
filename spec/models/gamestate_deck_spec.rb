require 'rails_helper'

RSpec.describe GamestateDeck, type: :model do
  describe 'Associations' do
    it { should belong_to(:player) }
    it { should belong_to(:game) }
  end
  describe 'Validations' do
    it { should validate_presence_of(:card_count) }
    it { should validate_numericality_of(:card_count) }
  end
end
