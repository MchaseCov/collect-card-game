require 'rails_helper'
require_relative 'game_scenario'

RSpec.describe Deathrattle, type: :model do
  include_context 'Shared Game Scenario'

  let(:token_archetype) do
    Archetype.create!(name: 'Token', description: 'xxxxx', resource_type: 'hybrid', color: 'slate')
  end

  let(:lioness_constant) do
    CardConstant.create(name: 'Protective Lioness', tribe: 'Beast', archetype: archetype)
  end
  let(:lioness_reference) do
    CardReference.create(cost: 5, attack: 5, health: 5,
                         card_type: 'PartyCard', card_constant: lioness_constant)
  end

  let(:lioness_token_constant) do
    CardConstant.create(name: 'Lion Cub', tribe: 'Beast', archetype: token_archetype,
                        summoner: lioness_constant)
  end
  let(:lioness_token_reference) do
    CardReference.create(cost: 2, attack: 2, health: 2,
                         card_type: 'PartyCard', card_constant:  lioness_token_constant)
  end

  subject do
    Deathrattle.create!(
      card_constant: lioness_constant,
      target: %w[invoking_card],
      action: 'summon_token',
      modifier: 2,
      body_text: 'Summon two 2/2 lion cubs.'
    )
  end

  it 'Is a valid deathrattle' do
    expect(subject).to be_valid
  end

  describe 'Token Deathrattle Testing' do
    include_context 'Shared Game Scenario'

    let(:lioness_card_for_testing) do
      game.player_one.gamestate_deck.cards.create!(cost: lioness_reference.cost, health: lioness_reference.health, attack: lioness_reference.attack,
                                                   health_cap: lioness_reference.health, type: lioness_reference.card_type, card_constant: lioness_constant)
    end

    let(:player) { game.player_one }
    before(:each) do
      subject
      lioness_constant
      lioness_reference
      lioness_token_constant
      lioness_token_reference
      player.party_cards.in_battlefield.each(&:return_to_hand)
      player.party_cards.first(5).each_with_index do |c, i|
        c.chosen_position = i + 1
        c.enter_play
      end
      lioness_card_for_testing.chosen_position = 3
      lioness_card_for_testing.enter_play
    end

    it 'Successfully enters battle' do
      expect(lioness_card_for_testing.position).to eql(3)
      expect(player.cards.in_battlefield).to include(lioness_card_for_testing)
      expect(player.cards.in_battlefield.order(:position).pluck(:position)).to match_array((1..6).to_a)
      expect(lioness_card_for_testing.deathrattle).to eq(subject)
    end

    it 'Spawns Tokens' do
      lioness_card_for_testing.take_damage(10)
      expect(player.cards.in_battlefield.order(:position).pluck(:position)).to match_array((1..7).to_a)
    end

    it 'Spawns tokens beginning in the deathrattle position, incrementing' do
      non_lion_cards = player.cards.in_battlefield.to_a - [lioness_card_for_testing]
      lioness_card_for_testing.take_damage(10)
      summoned_tokens = player.cards.in_battlefield - non_lion_cards
      summoned_tokens.each_with_index { |t, i| expect(t.position).to eql(lioness_card_for_testing.position + i) }
    end
  end
end
