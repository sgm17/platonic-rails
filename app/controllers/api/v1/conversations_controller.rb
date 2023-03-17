class Api::V1::ConversationsController < ApplicationController
    before_action :current_user
  
    # GET /api/v1/conversations
    def index
      conversations = @current_user.conversations.map do |conversation|
        conversation.as_json(
          except: [:created_at, :updated_at],
          include: {
            user1: {},
            user2: {}
          }
        )
      end
      render json: conversations
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