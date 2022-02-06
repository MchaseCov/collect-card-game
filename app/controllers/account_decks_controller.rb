class AccountDecksController < ApplicationController
  def index; end

  def new
    @races = Race.all
    @archetypes = Archetype.where.not(name: 'Neutral').all
    @account_deck = AccountDeck.new
  end

  def create
    @account_deck = AccountDeck.new(account_deck_params)
    if @account_deck.save
      redirect_to @account_deck
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update; end

  def destroy; end

  private

  def account_deck_params
    params.require(:account_deck).permit(:name, :race_id, :archetype_id)
  end
end
