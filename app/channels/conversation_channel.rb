class ConversationChannel < ApplicationCable::Channel
  def subscribed
    params[:conversation_ids].each do |id|
      conversation = Conversation.find(id)
      stream_for conversation
    end
  end

  def new_message(data)
    data = data['data']

    conversation = Conversation.find(data['conversation_id'])

    message = conversation.messages.build(
      message: data['message'], 
      user_id: data['user_id'], 
      creation_date: data['creation_date']
    )

    if message.save
      ConversationBroadcastJob.perform_later(message)
    end
  end

  def new_conversation(data)
    data = data['data']

    conversation = @current_user.initiated_conversations.build(user1_id: @current_user.id, user2_id: data['user_id'])

    if conversation.save
      ConversationBroadcastJob.perform_later(conversation)
    end
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
