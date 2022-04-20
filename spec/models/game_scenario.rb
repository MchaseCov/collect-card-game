shared_context 'Shared Game Scenario' do
  # Create two distinct users
  let(:user) { User.create!(email: 'foo@bar.com', password: '123123123') }
  let(:user_two) { User.create!(email: 'foo2@bar.com', password: '123123123') }

  # Create two different archetypes for comparison
  let(:archetype) { Archetype.create!(name: 'Ranger', description: 'RangerDesc', resource_type: 'hybrid') }
  let(:archetype_two) { Archetype.create!(name: 'Wizard', description: 'WizardDesc', resource_type: 'mana') }

  # Create race
  let(:race) do
    Race.create!(name: 'Human', description: 'Humandesc', health_modifier: 0, cost_modifier: 0, resource_modifier: 0)
  end

  # Create test card constant
  let(:card_constant) { CardConstant.create!(name: 'TestCard', tribe: 'Beast', archetype_id: archetype.id) }
  let(:card_constant_two) { CardConstant.create!(name: 'TestCard Two', archetype_id: archetype_two.id) }

  let(:card_reference) do
    CardReference.create!(cost: 1, attack: 5, health: 10, card_type: 'PartyCard', card_constant_id: card_constant.id)
  end

  let(:card_reference_two) do
    CardReference.create!(cost: 5, attack: 2, health: 4, card_type: 'PartyCard',
                          card_constant_id: card_constant_two.id)
  end

  let(:queued_deck_user_one) do
    deck = AccountDeck.create!(name: 'rspec deck',
                               user_id: user.id,
                               card_count: 30,
                               archetype_id: archetype.id,
                               race_id: race.id)
    30.times { deck.card_references << card_reference }
    deck
  end

  let(:queued_deck_user_two) do
    deck = AccountDeck.create!(name: 'rspec deck',
                               user_id: user_two.id,
                               card_count: 30,
                               archetype_id: archetype_two.id,
                               race_id: race.id)
    30.times { deck.card_references << card_reference_two }
    deck
  end

  let(:game) do
    Game.form_game(queued_deck_user_one, queued_deck_user_two)
  end

  let(:buff) do
    Buff.create!(name: 'Bestial Strength', target_method: 'increase_health_cap',
                 removal_method: 'decrease_health_cap', modifier: 2)
  end
end
