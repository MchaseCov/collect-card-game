class HomeController < ApplicationController
  def index
    @game = current_user.games.last
    @decks = current_user.account_decks.where(card_count: 30).all
  end
end
