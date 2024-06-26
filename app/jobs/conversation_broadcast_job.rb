class ConversationBroadcastJob < ApplicationJob
  queue_as :default

  def perform(conversation)
    new_conversation = conversation.as_json(include: {
      messages: {},
      user1: {
        include: {
          university: {},
          faculty: {},
          study: {}
        }
      },
      user2: {
        include: {
          university: {},
          faculty: {},
          study: {}
        }
      },
    })

    user1 = User.find(conversation.user1_id)
    user2 = User.find(conversation.user2_id)

    json = {"new_conversation" => new_conversation}

    ConversationChannel.broadcast_to(user1, json)
    ConversationChannel.broadcast_to(user2, json)
  end
end
