require 'rails_helper'

RSpec.describe Archetype, type: :model do
  subject { FactoryBot.build :archetype }

  context 'Archetype creation' do
    it { is_expected.to be_valid }
  end

  context 'validations' do
    context 'presence' do
      it { should validate_presence_of(:name) }
      it { should validate_presence_of(:description) }
      it { should validate_presence_of(:resource_type) }
      it { should validate_presence_of(:color) }
    end

    context 'inclusion' do
      it { should validate_inclusion_of(:resource_type).in_array(%w[mana energy hybrid]) }
    end
  end

  describe '#resource_color' do
    it 'returns sky when resource_type is mana' do
      subject.resource_type = 'mana'
      expect(subject.resource_color).to eql('sky')
    end
    it 'returns energy when resource_type is energy' do
      subject.resource_type = 'energy'
      expect(subject.resource_color).to eq('rose')
    end
    it 'returns violet when resource_type is hybrid' do
      subject.resource_type = 'hybrid'
      expect(subject.resource_color).to eq('violet')
    end
  end
end
