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

  # Create test card parents
  let(:party_card_parent) do
    PartyCardParent.create!(name: 'TestCard', cost_default: 1, attack_default: 5, health_default: 10,
                            archetype_id: archetype.id, tribe: 'Beast')
  end

  let(:party_card_parent_two) do
    PartyCardParent.create!(name: 'TestCard_Two', cost_default: 5, attack_default: 2, health_default: 4,
                            archetype_id: archetype_two.id)
  end

  let(:queued_deck_user_one) do
    deck = AccountDeck.create!(name: 'rspec deck',
                               user_id: user.id,
                               card_count: 30,
                               archetype_id: archetype.id,
                               race_id: race.id)
    30.times { deck.party_card_parents << party_card_parent }
    deck
  end

  let(:queued_deck_user_two) do
    deck = AccountDeck.create!(name: 'rspec deck',
                               user_id: user_two.id,
                               card_count: 30,
                               archetype_id: archetype_two.id,
                               race_id: race.id)
    30.times { deck.party_card_parents << party_card_parent_two }
    deck
  end

  let(:game) do
    game = Game.create!
    game.send(:populate_players, queued_deck_user_one, queued_deck_user_two)
    game.send(:populate_decks, queued_deck_user_one, queued_deck_user_two)
    game
  end

  let(:buff) do
    Buff.create!(name: 'Bestial Strength', target_method: 'increase_health_cap',
                 removal_method: 'decrease_health_cap', modifier: 2)
  end
end
