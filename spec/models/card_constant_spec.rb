require 'rails_helper'

RSpec.describe CardConstant, type: :model do
  describe 'Associations' do
    it { should belong_to(:archetype) }
    it { should have_many(:keywords) }
  end
  describe 'Validations' do
    it { should validate_presence_of(:name) }
  end
end
