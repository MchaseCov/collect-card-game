// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "channels"
import connectToGameChannel from "./channels/game_channel"

if (window.location.pathname.split('/')[1] === 'multiplayer_games' || window.location.pathname.split('/')[1] === 'singleplayer_games') {
  if (game, player) {
    connectToGameChannel(game, player)
  }
};
