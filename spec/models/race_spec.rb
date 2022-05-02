require 'rails_helper'

RSpec.describe Race, type: :model do
  subject { FactoryBot.build :race }

  context 'Race creation' do
    it { is_expected.to be_valid }
  end

  context 'validations' do
    context 'presence' do
      it { should validate_presence_of(:name) }
      it { should validate_presence_of(:description) }
      it { should validate_presence_of(:health_modifier) }
      it { should validate_presence_of(:cost_modifier) }
      it { should validate_presence_of(:resource_modifier) }
    end
    context 'numericality' do
      it { should validate_numericality_of(:health_modifier) }
      it { should validate_numericality_of(:cost_modifier) }
      it { should validate_numericality_of(:resource_modifier) }
    end
  end

  it 'cannot have modifiers exceeding 10' do
    subject.health_modifier = 11
    subject.cost_modifier = 11
    subject.resource_modifier = 11
    expect(subject).to_not be_valid
  end
  it 'cannot have modifiers below -10' do
    subject.health_modifier = -11
    subject.cost_modifier = -11
    subject.resource_modifier = -11
    expect(subject).to_not be_valid
  end
end
