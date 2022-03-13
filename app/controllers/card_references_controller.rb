class CardReferencesController < ApplicationController
  def index
    @account_deck = current_user.account_decks.find(params[:account_deck_id]) if params[:account_deck_id]
    @card_references =
      if params[:name].in?(%w[Barbarian Wizard Ranger Neutral])
        CardReference.includes(card_constant: :archetype).where(card_constant: { archetype: { name: params[:name] } }).all
      else
        CardReference.includes(card_constant: :archetype).all
      end
  end

  # Could be used as a thumbnailing lazy loader but unsure if this worth doing when already joining to the PCParent table in game
  # def show
  # @card = PartyCardParent.includes(:archetype).find(params[:id])
  # end
end
