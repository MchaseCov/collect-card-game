class AccountDecksController < ApplicationController
  before_action :set_current_user_account_deck, only: %i[show insert_card remove_card destroy_all_cards destroy]
  before_action :set_card, only: %i[insert_card remove_card]

  def index
    @account_decks = current_user.account_decks.all
  end

  def show; end

  def new
    @races = Race.all
    # Barbarians are only disabled because their cards effects are not ready!
    @archetypes = Archetype.where.not(name: 'Neutral').where.not(name: 'Token').where.not(name: 'Barbarian').all
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

  def insert_card
    @account_deck.add_card(@card)
  end

  def remove_card
    @account_deck.destroy_card(@card)
  end

  def destroy
    @account_deck.destroy
    redirect_to account_decks_path, status: :see_other
  end

  def destroy_all_cards
    @account_deck.destroy_all_cards
  end

  private

  def account_deck_params
    params.require(:account_deck).permit(:name, :race_id, :archetype_id)
  end

  def set_current_user_account_deck
    @account_deck = current_user.account_decks.find(params[:id])
  end

  def set_card
    @card = CardReference.find(params[:card_id])
  end
end
