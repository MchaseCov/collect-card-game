require 'rails_helper'

RSpec.describe PartyCardParent, type: :model do
  subject do
    described_class.new(name: 'Card Name',
                        cost_default: 5,
                        attack_default: 5,
                        health_default: 5,
                        tribe: 'tribe',
                        archetype: 'archetype',
                        body: 'body')
  end

  it 'is valid with valid attributes' do
    expect(subject).to be_valid
  end
  it 'is not valid without a name' do
    subject.name = nil
    expect(subject).to_not be_valid
  end
  it 'is not valid without a cost_default' do
    subject.cost_default = nil
    expect(subject).to_not be_valid
  end
  it 'is not valid without a attack_default' do
    subject.attack_default = nil
    expect(subject).to_not be_valid
  end
  it 'is not valid without a health_default' do
    subject.health_default = nil
    expect(subject).to_not be_valid
  end
  it 'is not valid without a tribe' do
    subject.tribe = nil
    expect(subject).to_not be_valid
  end
  it 'is not valid without a archetype' do
    subject.archetype = nil
    expect(subject).to_not be_valid
  end
  it 'is valid without a body' do
    subject.body = nil
    expect(subject).to be_valid
  end
end
