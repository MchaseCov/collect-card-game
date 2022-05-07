class AbilityTrigger < ApplicationRecord
  belongs_to :ability

  enum ability_type: { draw_cards: 0,
                       recieve_damage: 1,
                       spawn_token: 2 }

  enum ability_trigger: { passive: 0,
                          instant: 1,
                          death: 2,
                          end_turn: 3,
                          cast_spell: 4,
                          play_party: 5,
                          take_damage: 6 }

  enum ability_group: { source: 0,
                        specified: 1,
                        adjacent: 2,
                        all: 3 }

  enum ability_alignment: { all: 0,
                            friendly: 1,
                            opponent: 2 }

  enum ability_target_type: { party_and_player: 0,
                              party: 1,
                              player: 2,
                              hand_spell: 3,
                              hand_party: 4 }
end
