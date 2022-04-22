import consumer from "channels/consumer"
if (window.location.pathname.split('/')[1] === 'home') {

  consumer.subscriptions.create("QueueChannel", {
    connected() {
    },

    disconnected() {
    },

    received(data) {
      if (data.game_formed) window.location.href = data.game_url
    },
  });
}