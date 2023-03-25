class DeleteConversationBroadcastJob < ApplicationJob
  queue_as :default

  def perform(conversation_json)
    user1 = User.find(conversation_json['user1_id'])
    user2 = User.find(conversation_json['user2_id'])

    json = {"delete_conversation" => {"id" => conversation_json['id'] } }

    p user1, user2, json

    ConversationChannel.broadcast_to(user1, json)
    ConversationChannel.broadcast_to(user2, json)
  end
end
