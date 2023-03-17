class ConversationsBroadcastJob < ApplicationJob
  queue_as :default

  def perform(user, conversations)
    json = {"conversations" => conversations}
    ConversationChannel.broadcast_to(user, json)
  end
end
