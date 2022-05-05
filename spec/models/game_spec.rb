require 'rails_helper'
require_relative 'example_game'

RSpec.describe Game, type: :model do
  include_context 'Example Game Creation'
  subject { game }

  context 'Creation' do
    it { is_expected.to be_valid }
  end

  describe 'Associations' do
    it { should have_many(:players) }
    it { should have_one(:player_one) }
    it { should have_one(:player_two) }
    it { should have_one(:current_player) }
  end

  # CREATABLE
  # METHODS RELATED TO NEW GAME CREATION

  context 'Creatable' do
    subject { started_game }
    describe '#prepare_player' do
      it 'player.race == account_deck.race' do
        expect(subject.player_one.race_id).to eq(user_one_account_deck.race_id)
        expect(subject.player_two.race_id).to eq(user_two_account_deck.race_id)
      end
      it 'player.archetype == account_deck.archetype' do
        expect(subject.player_one.archetype_id).to eq(user_one_account_deck.archetype_id)
        expect(subject.player_two.archetype_id).to eq(user_two_account_deck.archetype_id)
      end
      it 'player.health == account_deck.race.health_modifier + 30' do
        expect(subject.player_one.health_cap).to eq(user_one_account_deck.race.health_modifier + 30)
        expect(subject.player_two.health_cap).to eq(user_two_account_deck.race.health_modifier + 30)
      end
      it 'player.cost == account_deck.race.cost_modifier' do
        expect(subject.player_one.cost_current).to eq(user_one_account_deck.race.cost_modifier)
        expect(subject.player_two.cost_current).to eq(user_two_account_deck.race.cost_modifier)
      end
      it 'player.resource == account_deck.race.resource_modifier' do
        expect(subject.player_one.resource_current).to eq(user_one_account_deck.race.resource_modifier)
        expect(subject.player_two.resource_current).to eq(user_two_account_deck.race.resource_modifier)
      end
    end

    describe '#prepare_deck' do
      it 'Creates a Card for every Card Reference' do
        expect(subject.player_one.gamestate_deck.cards.length).to eq(30)
        expect(subject.player_two.gamestate_deck.cards.length).to eq(30)
      end
    end
    describe '#draw_mulligan_cards' do
      it 'Gives player one 3 mulligan cards' do
        expect(subject.player_one.cards.in_mulligan.length).to eq(3)
      end
      it 'Gives player two 4 mulligan cards' do
        expect(subject.player_two.cards.in_mulligan.length).to eq(4)
      end
    end
  end

  # After mulligan phase, begin the first turn of the ongoing game phase
  context '#begin_first_turn' do
    subject { started_game }

    it 'moves mulligan cards into hand' do
      original_p1_card_ids = subject.player_one.cards.in_mulligan.pluck(:id).to_set
      original_p2_card_ids = subject.player_two.cards.in_mulligan.pluck(:id).to_set
      subject.begin_first_turn
      expect(original_p1_card_ids.subset?(subject.player_one.cards.in_hand.pluck(:id).to_set)).to be true
      expect(original_p2_card_ids.subset?(subject.player_two.cards.in_hand.pluck(:id).to_set)).to be true
    end

    it 'sets game status to ongoing' do
      subject.begin_first_turn
      expect(subject.status).to eq 'ongoing'
    end

    it 'sets an initial turn_time value' do
      subject.begin_first_turn

      expect(subject.turn_time).to be_present
    end

    it 'calls #start_of_turn_actions' do
      expect(subject).to receive(:start_of_turn_actions)
      subject.begin_first_turn
    end
  end

  context '#play_card' do
    subject { ongoing_game }

    describe 'When player can afford the card' do
      it 'puts the card into play' do
        test_card = subject.current_player.party_cards.in_hand.first
        subject.player_one.cost_current = subject.current_player.party_cards.in_hand.first.cost
        subject.play_card(test_card)
        expect(test_card.location).to eq('battlefield')
        expect(test_card.status).to eq('sleeping')
      end
    end
  end

  context '#end_turn' do
    subject { ongoing_game }

    it 'puts the current player cards to sleep' do
      allow(subject).to receive(:broadcast_board_entry_phase)
      test_card = subject.current_player.party_cards.first
      test_card.update_columns(status: 'attack_ready', location: 'battlefield')
      subject.end_turn
      expect(test_card.reload.status).to eq('sleeping')
    end

    it 'Updates the Turn column, thus changing the current_player' do
      current_turn = subject.turn
      initial_current_player = subject.current_player
      subject.end_turn
      expect(subject.turn).to_not eql(current_turn)
      expect(subject.current_player).to eql(subject.opposing_player_of(initial_current_player))
    end
    it 'calls #start_of_turn_actions' do
      expect(subject).to receive(:start_of_turn_actions)
      subject.begin_first_turn
    end
  end
end
