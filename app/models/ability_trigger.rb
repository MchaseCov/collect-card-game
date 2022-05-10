class AbilityTrigger < ApplicationRecord
  belongs_to :ability
  belongs_to :card_constant

  scope :battlecry, -> { where(trigger: 'instant') }

  enum trigger: { passive: 0,
                  instant: 1,
                  death: 2,
                  end_turn: 3,
                  cast_spell: 4,
                  play_party: 5,
                  take_damage: 6 }

  enum target_scope: { source: 0,
                       specified: 1,
                       adjacent: 2,
                       all_in_group: 3 }, _prefix: :scopes_to

  enum alignment: { both_teams: 0,
                    friendly_team: 1,
                    opponent_team: 2 }

  enum target_type: { party_and_player: 0,
                      party: 1,
                      player: 2,
                      hand_spell: 3,
                      hand_party: 4 }

  enum additional_scoping: {
    'tribe,Beast': 0
  }

  def trigger(triggering_card)
    @triggering_card = triggering_card
    targets = find_targets
    ability.trigger(targets)
  end

  private

  def find_targets
    # Faster way to simply return the source and skip the search
    return @triggering_card if scopes_to_source?

    # Select a team by alignment and then specify the group by key
    target_group = method(alignment).call[target_type.to_sym].flatten
    # Scope the group
    scoped_target = method(target_scope).call(target_group)
    # Additional optional scoping before returning target(s)
    additional_scoping ? additionally_scope(scoped_target) : scoped_target
  end

  def friendly_team
    player = @triggering_card.player
    team_data([player])
  end

  def opponent_team
    player = @triggering_card.game.opposing_player_of(@triggering_card.player)
    team_data([player])
  end

  def both_teams
    player = @triggering_card.player
    op_player = player.game.opposing_player_of(player)
    team_data([player, op_player])
  end

  def team_data(players)
    {
      player: players,
      party: players.map { |p| p.party_cards.in_battlefield },
      party_and_player: players.map { |p| [p, p.party_cards.in_battlefield] },
      hand_spell: players.map { |p| p.spell_cards.in_hand },
      hand_party: players.map { |p| p.party_cards.in_hand }
    }
  end

  #  group methods
  def specified(target_group)
    if ability.player_input?
      target_group.find { |t| t[:id] == @triggering_card.current_target }
    else
      target_group.sample(ability.random)
    end
  end

  def adjacent(target_group)
    initial_target = target_group.find { |t| t[:id] == @triggering_card.current_target }
    target_group.where(position: initial_target.position + 1).or(target_group.where(position: initial_target.position - 1))
  end

  def all_in_group(target_group)
    target_group
  end

  def additionally_scope(scoped_target)
    scope = additional_scoping.split(',')
    scoped_target.select { |t| t.send(scope[0]) == scope[1] }
  end
end
