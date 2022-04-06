module BoardPositionable
  extend ActiveSupport::Concern
  included do
    def shift_cards_right(position, amount = 1)
      shift_cards(position, amount)
    end

    def shift_cards_left(position, amount = 1)
      shift_cards(position, -amount)
    end

    def correct_all_positioning
      positions = party_cards.in_battlefield.order(:position).pluck(:position)
      return if positions.empty? || positions_already_ordered(positions)

      transaction do
        party_cards.in_battlefield.order(:position).each.with_index do |card, index|
          card.update_column(:position, index + 1)
        end
      end
    end

    private

    def shift_cards(position, amount)
      # Experimental, technically not injection safe but also only internally used
      party_cards.in_battlefield.where('position >= ?', position).update_all("position = position + #{amount}")
    end

    def positions_already_ordered(positions)
      positions.first == 1 && positions.each_cons(2).all? { |a, b| b == a + 1 }
    end
  end
end
