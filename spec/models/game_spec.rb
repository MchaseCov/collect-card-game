require 'rails_helper'

RSpec.describe Game, type: :model do
  describe 'Associations' do
    it { should belong_to(:winner).without_validating_presence }
  end
  describe 'Game Creation' do
    it 'Creates player one' do end
    it 'Creates player two' do end
    it 'Creates a duplicate gamestate deck of player one' do end
    it 'Creates a duplicate gamestate deck of player two' do end
  end
end
