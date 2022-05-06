module Cacheable
  extend ActiveSupport::Concern
  included do
    def return_cache_data
      if status == 'mulligan'
        return_mulligan_data
      else
        return_standard_data
      end
    end

    def return_standard_data
      p1 = player_one.reload
      p2 = player_two.reload
      { game: self,
        player_one: {
          player_data: p1,
          uid: p1.user_id,
          cards: {
            in_hand: p1.cards.in_hand.order(updated_at: :asc).to_a,
            in_battlefield: p1.party_cards.in_battlefield.order(:position).map(&:attributes),
            in_deck: p1.cards.in_deck.count,
            undrawnCard: p1.cards.in_overdraw.order(:updated_at).map(&:attributes).last
          }
        },
        player_two: {
          player_data: p2,
          uid: p2.user_id,
          cards: {
            in_hand: p2.cards.in_hand.order(updated_at: :asc).to_a,
            in_battlefield: p2.party_cards.in_battlefield.order(:position).map(&:attributes),
            in_deck: p2.cards.in_deck.count,
            undrawnCard: p2.cards.in_overdraw.order(:updated_at).map(&:attributes).last
          }
        } }
    end

    def return_mulligan_data
      p1 = player_one.reload
      p2 = player_two.reload
      { game: self,
        player_one: {
          player_data: p1,
          uid: p1.user_id,
          cards: {
            in_hand: p1.cards.in_mulligan.order(updated_at: :asc).to_a,
            in_deck: p1.cards.in_deck.count

          }
        },
        player_two: {
          player_data: p2,
          uid: p2.user_id,
          cards: {
            in_hand: p2.cards.in_mulligan.order(updated_at: :asc).to_a,
            in_deck: p2.cards.in_deck.count

          }
        } }
    end

    def curate_json_for_perspective(uid, cached_data)
      cached_data = cached_data.deep_symbolize_keys
      case uid
      when cached_data[:player_two][:uid]
        return_personalized_json(
          cached_data, :player_two
        )
      else
        return_personalized_json(
          cached_data, :player_one
        )
      end
    end

    def return_personalized_json(cached_data, player)
      opponent = (player == :player_one ? :player_two : :player_one)
      personalization = { player => :player, opponent => :opponent }

      cached_data.keys.each { |k| cached_data[personalization[k]] = cached_data.delete(k) if personalization[k] }
      cached_data[:opponent][:cards][:in_hand] = cached_data[:opponent][:cards][:in_hand].pluck(:id)
      cached_data[:player][:cards][:in_hand] = cached_data[:player][:cards][:in_hand].map(&:attributes)
      cached_data.to_json
    end
  end
end
