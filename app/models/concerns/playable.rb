# Handles the evaluation and calling of methods that put a card from the player's hand into play
module Playable
  extend ActiveSupport::Concern

  included do
    def playable?
      return false unless can_be_played

      spend_currency_method.call(self)
    end

    def enter_play
      enter_play_tasks
      game.broadcast_basic_update(self)
    end

    private

    def can_be_played
      can_be_afforded && additional_requirements_met
    end

    def can_be_afforded
      required_currency >= cost
    end

    def additional_requirements_met
      additional_requirements.all?
    end
  end
end
