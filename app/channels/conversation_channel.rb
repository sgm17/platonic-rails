class ConversationChannel < ApplicationCable::Channel
  def subscribed
    stream_for current_user
  end

  def delete_conversation(data)
    conversation = Conversation.find(data['id'])

    json = conversation.as_json()

    if conversation.destroy
      DeleteConversationBroadcastJob.perform_later(json)
    end
  end

  def create_conversation(data)
    conversation = current_user.initiated_conversations.build(user2_id: data["user2_id"])

    if conversation.save
      
      message = conversation.messages.build(
        body: data['body'], 
        user_id: data['user_id'], 
        creation_date: data['creation_date']
      )

      if message.save
        PushNotificationJob.perform_later(data["user2_id"], "#{current_user.name} te ha enviado un mensaje:", data["body"], "chat", current_user.as_json.transform_values(&:to_s))

        ConversationBroadcastJob.perform_later(conversation)
      end
    end
  end

  def get_conversations
    conversations = current_user.conversations.includes(:user1, :user2, messages: [:user]).map do |conversation|
      conversation.as_json(
        except: [:created_at, :updated_at],
        include: {
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
          messages: { include: :user }
        }
      )
    end
  
    ConversationsBroadcastJob.perform_later(current_user, conversations)
  end

  def unsubscribed
  end
end
