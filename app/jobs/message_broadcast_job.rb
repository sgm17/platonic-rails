class MessageBroadcastJob < ApplicationJob
  queue_as :default

  def perform(message)
    message = Message.new(message)
    conversation = Conversation.find(message[:conversation_id])
    MessageChannel.broadcast_to(conversation, message.as_json)
  end
end
