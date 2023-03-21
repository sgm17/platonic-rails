class MessageBroadcastJob < ApplicationJob
  queue_as :default

  def perform(message)
    message = Message.new(message)
    conversation = Conversation.find(message[:conversation_id])

    json = {"message" => message.as_json}

    MessageChannel.broadcast_to(conversation, json)
  end
end
