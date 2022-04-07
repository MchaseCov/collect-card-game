// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "channels"
import turboStreamQueue from './turbo_stream_queuer'


if(window.location.pathname.split('/')[1] === 'multiplayer_games' || window.location.pathname.split('/')[1] === 'singleplayer_games') {
  document.addEventListener('turbo:before-stream-render', async (event) => {turboStreamQueue(event)});
  };
