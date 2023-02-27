class ConversationChannel < ApplicationCable::Channel
  def subscribed
    params[:conversation_ids].each do |id|
      conversation = Conversation.find(id)
      stream_for conversation
    end
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
