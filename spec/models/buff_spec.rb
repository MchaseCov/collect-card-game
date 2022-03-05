require 'rails_helper'

RSpec.describe Buff, type: :model do
  subject do
    described_class.create!(name: 'Bestial Strength', target_method: 'increase_health_cap',
                            removal_method: 'decrease_health_cap', modifier: 2)
  end

  describe 'Associations' do
    it { should belong_to(:keyword).optional }
    it { should have_many(:active_buffs) }
  end
  describe 'Validations' do
    %i[name target_method removal_method modifier].each do |attri|
      it { should validate_presence_of(attri) }
    end
  end
end
