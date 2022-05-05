require 'rails_helper'

shared_examples_for 'playable' do
  context '#playable?' do
    describe 'When can_be_played is true' do
      it "spends the player's respective currency" do
        allow(subject).to receive(:can_be_played) { true }
        player_currency_method = subject.send(:respective_player_currency_spender)
        expect(subject.player).to receive(player_currency_method.name)
        subject.playable?
      end
    end
    describe 'When can_be_played is false' do
      it 'returns false' do
        allow(subject).to receive(:can_be_played) { false }
        expect(subject.playable?).to eq(false)
      end
      it "does not spend the player's respective currency" do
        allow(subject).to receive(:can_be_played) { false }
        player_currency_method = subject.send(:respective_player_currency_spender)
        expect(subject.player).to_not receive(player_currency_method.name)
        subject.playable?
      end
    end
  end
end
