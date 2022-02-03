require 'rails_helper'

RSpec.describe Game, type: :model do
  describe 'Associations' do
    it { should belong_to(:winner).without_validating_presence }
  end
end
