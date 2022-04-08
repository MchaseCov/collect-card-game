module Cacheable
  extend ActiveSupport::Concern
  included do
    def return_cache_data
      p1 = player_one.reload
      p2 = player_two.reload
      { game: self,
        player_one: {
          player_data: p1,
          uid: p1.user.id,
          cards: {
            in_hand: p1.cards.in_hand.includes(:keywords, card_constant: [:archetype]).order(updated_at: :asc).to_a,
            in_battlefield: p1.party_cards.in_battlefield.includes(:keywords,
                                                                   card_constant: [:archetype]).order(:position).to_a,
            in_deck: p1.cards.in_deck.count
          }
        },
        player_two: {
          player_data: p2,
          uid: p2.user.id,
          cards: {
            in_hand: p2.cards.in_hand.includes(:keywords, card_constant: [:archetype]).order(updated_at: :asc).to_a,
            in_battlefield: p2.party_cards.in_battlefield.includes(:keywords,
                                                                   card_constant: [:archetype]).order(:position).to_a,
            in_deck: p2.cards.in_deck.count
          }
        } }
    end

    def curate_cache_for_perspective(uid, cached_data)
      case uid
      when cached_data[:player_two][:uid]
        return_player_perspective(
          cached_data[:player_two], cached_data[:player_one]
        )
      else
        return_player_perspective(
          cached_data[:player_one], cached_data[:player_two]
        )
      end
    end

    def return_player_perspective(first_person, opponent)
      {
        first_person_player: first_person[:player_data],
        first_person_player_cards: first_person[:cards],
        opposing_player: opponent[:player_data],
        opposing_player_cards: opponent[:cards],
        opposing_player_cards_in_hand: opponent[:cards][:in_hand].pluck(:id)
      }
    end
  end
end