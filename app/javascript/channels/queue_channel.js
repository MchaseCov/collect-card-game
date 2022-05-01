import consumer from "channels/consumer"

if (window.location.pathname.split('/')[1] !== 'multiplayer_games') {
  const form = document.getElementById('queue-form')
  const button = document.getElementById('queue-button')
  consumer.subscriptions.create("QueueChannel", {
    connected() {
    },

    disconnected() {
    },

    received(data) {
      if (data.in_queue) this.indicate_joined_queue()
      if (data.exit_queue) this.indicate_exit_queue()
      if (data.game_formed) window.location.href = data.game_url
    },

    indicate_joined_queue(){
      form.action = "/queue/leave"
      button.value = "IN QUEUE"
      button.classList.add('bg-lime-500')
    },
    indicate_exit_queue(){
      form.action = "/queue/join"
      button.value = "Queue this deck!"
      button.classList.remove('bg-lime-500')
    }
  });
}