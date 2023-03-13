class Api::V1::ConversationsController < ApplicationController
    before_action :current_user
  
    # GET /api/v1/conversations
    def index
      conversations = current_user.conversations.includes(:messages, :user1, :user2).map do |conversation|
        other_user = conversation.user1_id == current_user.id ? conversation.user2 : conversation.user1
        last_message = conversation.messages.last
        {
          id: conversation.id,
          user: other_user.as_json(
            except: [:meet_status, :sex_to_meet, :university_to_meet_id, :created_at, :updated_at],
            include: {
              university: { only: [:id, :name, :simple_name] },
              faculty: { only: [:id, :faculty_name] },
              study: { only: [:id, :name] }
            }
          ),
          messages: conversation.messages.as_json(
            except: [:updated_at])
        }
      end
      render json: conversations
    end

    # POST /api/v1/conversations
    def create
      conversation = current_user.initiated_conversations.build(user1_id: current_user.id, user2_id: params[:user_id])

      if conversation.save
        ConversationBroadcastJob.perform_later(conversation)
        render json: conversation, status: :created
      else
        render json: { errors: conversation.errors.full_messages }, status: :unprocessable_entity
      end
    end
end  