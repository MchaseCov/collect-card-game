require 'rails_helper'

RSpec.describe User, type: :model do
  subject { FactoryBot.build :user }

  context 'User creation' do
    it { is_expected.to be_valid }
  end

  context 'when email is empty' do
    let(:user) { FactoryBot.build(:user, email: nil) }
    it 'should not be valid' do
      expect(user.valid?).to be false
    end

    it 'should not save' do
      expect(user.save).to be false
    end
  end

  describe 'validations' do
    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
  end
end
