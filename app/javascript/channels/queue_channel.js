import consumer from "channels/consumer"

consumer.subscriptions.create("QueueChannel", {
  connected() {
  },

  disconnected() {
  },

  received(data) {
    if(data.game_formed) window.location.href = data.game_url
  },
});