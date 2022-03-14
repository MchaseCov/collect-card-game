class CardReferencesController < ApplicationController
  before_action :set_deck, only: [:index], if: -> { params[:account_deck_id] }

  def index
    @card_references =
      if params[:name].in?(%w[Barbarian Wizard Ranger Neutral])
        archetype = Archetype.find_by(name: params[:name])
        CardReference.includes(card_constant: %i[archetype keywords]).where(card_constant: { archetype: archetype }).all
      else
        CardReference.includes(card_constant: %i[archetype keywords]).all
      end
  end

  private

  def set_deck
    @account_deck = current_user.account_decks.find(params[:account_deck_id])
  end

  # Could be used as a thumbnailing lazy loader but unsure if this worth doing when already joining to the PCParent table in game
  # def show
  # @card = PartyCardParent.includes(:archetype).find(params[:id])
  # end
end
