require 'rails_helper'

RSpec.describe Keyword, type: :model do
  describe 'Associations' do
    it { should belong_to(:party_card_parent) }
  end
  describe 'Validations' do
    it { should validate_presence_of(:type) }
    it { should validate_presence_of(:player_choice) }
    it { should validate_presence_of(:target) }
    it { should validate_presence_of(:modifier) }
    it { should validate_numericality_of(:modifier) }
    it { should validate_inclusion_of(:type).in_array(%w[Deathrattle Battlecry]) }
  end
end
