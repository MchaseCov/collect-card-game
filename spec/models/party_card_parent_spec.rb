require 'rails_helper'

RSpec.describe PartyCardParent, type: :model do
  describe 'Associations' do
    it { should belong_to(:archetype) }
  end
  describe 'Validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:cost_default) }
    it { should validate_presence_of(:attack_default) }
    it { should validate_presence_of(:health_default) }
    it { should validate_presence_of(:tribe) }
  end
end
