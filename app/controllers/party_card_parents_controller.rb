class PartyCardParentsController < ApplicationController
  def index
    @account_deck = current_user.account_decks.find(params[:account_deck_id]) if params[:account_deck_id]
    @party_card_parents =
      if params[:name].in?(%w[Barbarian Wizard Ranger Neutral])
        PartyCardParent.includes(:archetype).where(archetype: { name: params[:name] }).all
      else
        PartyCardParent.includes(:archetype).all
      end
  end

  def show; end
end
