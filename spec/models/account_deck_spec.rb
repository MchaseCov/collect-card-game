require 'rails_helper'

RSpec.describe AccountDeck, type: :model do
  describe 'Associations' do
    it { should belong_to(:user) }
    it { should belong_to(:race) }
    it { should belong_to(:archetype) }
  end
  describe 'Validations' do
    it { should validate_presence_of(:name) }
  end
end
