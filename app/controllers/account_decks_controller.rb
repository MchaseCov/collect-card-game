class AccountDecksController < ApplicationController
  def index
    @account_decks = current_user.account_decks.all
  end

  def show
    @account_deck = current_user.account_decks.find(params[:id])
  end

  def new
    @races = Race.all
    @archetypes = Archetype.where.not(name: 'Neutral').all
    @account_deck = current_user.account_decks.build
  end

  def create
    @account_deck = current_user.account_decks.build(account_deck_params)
    if @account_deck.save
      redirect_to @account_deck
    else
      puts @account_deck.errors.full_messages
      @races = Race.all
      @archetypes = Archetype.where.not(name: 'Neutral').all
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update; end

  def insert_party_card
    return unless params[:account_deck_id] && params[:card_id]

    account_deck = current_user.account_decks.find(params[:account_deck_id])
    card = PartyCardParent.find(params[:card_id])
    account_deck.party_card_parents << card if card.archetype.name == 'Neutral' || account_deck.archetype.name
  end

  def destroy; end

  private

  def account_deck_params
    params.require(:account_deck).permit(:name, :race_id, :archetype_id)
  end
end
