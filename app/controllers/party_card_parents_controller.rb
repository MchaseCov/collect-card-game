class PartyCardParentsController < ApplicationController
  def index
    @party_card_parents =
      if params[:name].in?(%w[Barbarian Wizard Ranger Neutral])
        PartyCardParent.includes(:archetype).where(archetype: { name: params[:name] }).all
      else
        PartyCardParent.includes(:archetype).all
      end
  end

  def show; end
end
