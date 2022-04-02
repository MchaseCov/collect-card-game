module BoardPositionable
  extend ActiveSupport::Concern
  included do
    def shift_cards_right(position, amount = 1)
      shift_cards(position) { |card| card.increment_position(amount) }
    end

    def shift_cards_left(position, amount = 1)
      shift_cards(position) { |card| card.decrement_position(amount) }
    end

    private

    def shift_cards(position, &block)
      party_cards.in_battlefield.where('position >= ?', position).each(&block)
    end
  end
end
