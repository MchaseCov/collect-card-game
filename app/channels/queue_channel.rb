class QueueChannel < ApplicationCable::Channel
  def subscribed
    stream_from "queue_#{current_user.id}"
  end

  def unsubscribed
    GameQueueController.queue.reject! { |entry| entry[:user] == current_user.id }
  end
end
