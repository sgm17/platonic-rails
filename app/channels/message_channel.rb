class MessageChannel < ApplicationCable::Channel
  def subscribed
    params[:conversation_ids].each do |id|
      conversation = Conversation.find(id)
      stream_for conversation
    end
  end

  def new_message(data)
    conversation = Conversation.find(data['conversation_id'])
    current_user = User.find(data['user_id'])
    other_user = conversation.user1 == current_user ? conversation.user2 : conversation.user1

    message = conversation.messages.build(
      body: data['body'], 
      user_id: data['user_id'], 
      creation_date: data['creation_date']
    )

    if message.save
      PushNotificationJob.perform_later(other_user.id, "#{current_user.name} te ha enviado un mensaje:", data["body"], "chat", current_user.as_json.transform_values(&:to_s))
      MessageBroadcastJob.perform_later(message)
    end
  end

  def unsubscribed
  end
end