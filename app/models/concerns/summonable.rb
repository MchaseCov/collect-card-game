module Summonable
  extend ActiveSupport::Concern

  def summon_units(summon_type, amount = 1)
    amount_to_summon = [(7 - player.party_cards.in_battlefield.count), amount].min
    return unless amount_to_summon.positive?

    card_data = fetch_card_data(summon_type)
    create_space_for_units(amount)
    generate_cards(amount, card_data)
    player.correct_all_positioning # Fallback for all positioning issues
  end

  private

  def generate_cards(amount, card_data)
    @deck = gamestate_deck
    left_direction = right_direction = card_data[:position]
    amount.times do |i|
      generated_position = ((i.even? ? right_direction += 1 : left_direction -= 1))
      generated_card = @deck.cards.new(card_data)
      generated_card.buffs << @buffs if @buffs
      generated_card.attributes = card_data if @buffs # "Undo" the buff callbacks
      generated_card.position = generated_position
      generated_card.save
    end
  end

  # PRIVATE create_space_for_units: Private method called by prepare_to_summon_cards
  # Increments positions to create "gaps" for newly summoned cards.
  # Given an amount, it will create an equal amount of spaces on the left and right side of the invoking card,
  # favoring the right/greater side when an odd number is supplied.
  #
  # amount  -  The Integer amount of spaces to create
  def create_space_for_units(amount_to_summon)
    left_token_count = amount_to_summon / 2
    player.shift_cards_right(position + 1, amount_to_summon)
    increment_position(left_token_count)
  end

  def fetch_card_data(summon_type)
    case summon_type
    when 'token'
      token_data
    when 'copy'
      copy_data
    end
  end

  def token_data
    token = card_constant.token
    return unless token

    token_reference = token.card_reference
    { cost: token_reference.cost, health: token_reference.health, attack: token_reference.attack,
      health_cap: token_reference.health, location: 3, status: 3, type: 'PartyCard',
      card_constant: token, position: position }
  end

  def copy_data
    @buffs = buffs
    { cost: cost, health: health, attack: attack, health_cap: health_cap, location: 3,
      status: 3, type: 'PartyCard', card_constant: card_constant, position: position }
  end
end
