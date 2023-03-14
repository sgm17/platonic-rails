class Api::V1::ConversationsController < ApplicationController
    before_action :current_user
  
    # GET /api/v1/conversations
    def index
      conversations = @current_user.conversations.map do |conversation|
        other_user = conversation.user1_id == @current_user.id ? conversation.user2 : conversation.user1
        last_message = conversation.messages.last
        {
          id: conversation.id,
          user: other_user.as_json(
            except: [:meet_status, :sex_to_meet, :university_to_meet_id, :created_at, :updated_at],
          ),
          messages: conversation.messages.as_json(
            except: [:created_at, :updated_at])
        }
      end
      render json: conversations
    end

    # POST /api/v1/conversations
    def create
      conversation = @current_user.initiated_conversations.build(user1_id: @current_user.id, user2_id: params[:user_id])

      if conversation.save
        ConversationBroadcastJob.perform_later(conversation)
        render json: { id: conversation.id }, status: :created
      else
        render json: { errors: conversation.errors.full_messages }, status: :unprocessable_entity
      end
    end

    # DELETE /api/v1/conversations/:conversation_id
    def destroy
      conversation = Conversation.find(params[:id])
      
      if conversation.destroy
        render json: { destroyed: true }
      else
        render json: { destroyed: false }
      end
    end
end  