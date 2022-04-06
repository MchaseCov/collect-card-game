module BoardPositionable
  extend ActiveSupport::Concern
  included do
    def shift_cards_right(position, amount = 1)
      shift_cards(position, amount)
    end

    def shift_cards_left(position, amount = 1)
      shift_cards(position, -amount)
    end

    private

    def shift_cards(position, amount)
      # Experimental, technically not injection safe but also only internally used
      party_cards.in_battlefield.where('position >= ?', position).update_all("position = position + #{amount}")
    end
  end
end
