class ConversationBroadcastJob < ApplicationJob
  queue_as :default

  def perform(conversation)
    ConversationChannel.broadcast_to(conversation, conversation.as_json(include: :messages))
  end
end
