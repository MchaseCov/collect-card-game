require 'rails_helper'

RSpec.describe Archetype, type: :model do
  subject do
    described_class.new(name: 'Barbarian',
                        description: 'A fierce warrior with a rage for battle',
                        resource_type: 'energy')
  end

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
  it 'is not valid without a resource type' do
    subject.resource_type = nil
    expect(subject).to_not be_valid
  end
  it 'can have a resource of mana' do
    subject.resource_type = 'mana'
    expect(subject).to be_valid
  end
  it 'can have a resource of energy' do
    subject.resource_type = 'energy'
    expect(subject).to be_valid
  end
  it 'can have a resource of hybrid' do
    subject.resource_type = 'hybrid'
    expect(subject).to be_valid
  end
  it 'cannot have other resource type names' do
    subject.resource_type = 'magic'
    expect(subject).to_not be_valid
  end
end
