require 'rails_helper'

RSpec.describe Buff, type: :model do
  subject { FactoryBot.create(:buff) }

  context 'Creation' do
    it { is_expected.to be_valid }
  end

  describe 'Associations' do
    it { should have_and_belong_to_many(:keywords) }
    it { should have_many(:active_buffs) }
  end
  describe 'Validations' do
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
    it { should validate_numericality_of(:modifier).allow_nil }
  end
end
