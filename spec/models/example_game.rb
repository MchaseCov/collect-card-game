shared_context 'Example Game Creation' do
  let(:game) do
    game = FactoryBot.create(:game)
    game.player_one = FactoryBot.create(:player_one)
    game.player_two = FactoryBot.create(:player_two)
    game
  end

  let(:card_reference) { FactoryBot.create(:card_reference) }

  let(:user_one_account_deck) do
    deck = FactoryBot.create(:account_deck)
    30.times { deck.card_references << card_reference }
    deck
  end
  let(:user_two_account_deck) do
    deck = FactoryBot.create(:account_deck)
    30.times { deck.card_references << card_reference }
    deck
  end

  let(:started_game) do
    game.begin_game(user_one_account_deck, user_two_account_deck)
    allow(game).to receive(:broadcast_basic_update)
    allow(game).to receive(:broadcast_card_draw_animations)
    allow(game).to receive(:animate_end_of_mulligan)
    allow(game).to receive(:broadcast_card_play_animations)
    allow(game).to receive(:broadcast_board_entry_phase)
    game
  end

  let(:ongoing_game) do
    started_game.begin_first_turn
    started_game
  end
end
