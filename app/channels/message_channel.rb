class MessageChannel < ApplicationCable::Channel
  def subscribed
    params[:conversation_ids].each do |id|
      conversation = Conversation.find(id)
      stream_for conversation
    end
  end

  def new_message(data)
    conversation = Conversation.find(data['conversation_id'])

    message = conversation.messages.build(
      body: data['body'], 
      user_id: data['user_id'], 
      creation_date: data['creation_date']
    )

    if message.save
      MessageBroadcastJob.perform_later(message.as_json)
    end
  end

  def unsubscribed
  end
end