require 'rails_helper'

RSpec.describe Race, type: :model do
  subject do
    described_class.new(name: 'Dwarf',
                        description: "Dwarves are skilled warriors with an affinity for stone and metal work.
                        Racial bonuses:
                        Your hardy nature raises your total life by 5 points!",
                        health_modifier: 5,
                        cost_modifier: 0,
                        resource_modifier: 0)
  end
  it { should validate_uniqueness_of(:name) }

  it 'is valid with valid attributes' do
    expect(subject).to be_valid
  end
  it 'is not valid without a name' do
    subject.name = nil
    expect(subject).to_not be_valid
  end
  it 'is not valid without a description' do
    subject.description = nil
    expect(subject).to_not be_valid
  end
  it 'is not valid without a health modifier' do
    subject.health_modifier = nil
    expect(subject).to_not be_valid
  end
  it 'is not valid without a cost modifier' do
    subject.cost_modifier = nil
    expect(subject).to_not be_valid
  end
  it 'is not valid without a resource modifier' do
    subject.resource_modifier = nil
    expect(subject).to_not be_valid
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
